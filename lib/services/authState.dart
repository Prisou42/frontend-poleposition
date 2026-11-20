
import 'package:flutter/foundation.dart';
import 'authService.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isAuthenticated = false;
  bool isLoading = true;
  bool favoritesSetupCompleted = false;

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getMe();

      isAuthenticated = true;

      favoritesSetupCompleted =
          user['favorites_setup_completed'] == true;
    } catch (_) {
      await _authService.logoutLocal();

      isAuthenticated = false;
      favoritesSetupCompleted = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setAuthenticated(bool value) {
    isAuthenticated = value;

    if (!value) {
      favoritesSetupCompleted = false;
    }

    notifyListeners();
  }

  void setFavoritesSetupCompleted(bool value) {
    favoritesSetupCompleted = value;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      isAuthenticated = false;
      favoritesSetupCompleted = false;
      notifyListeners();
    }
  }
}

final authState = AuthState();


