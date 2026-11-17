
import 'package:flutter/foundation.dart';
import 'authService.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isAuthenticated = false;

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    try {
      await _authService.getMe();
      isAuthenticated = true;
    } catch (_) {
      await _authService.logoutLocal();
      isAuthenticated = false;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      isAuthenticated = false;
      notifyListeners();
    }
  }
}

final authState = AuthState();
