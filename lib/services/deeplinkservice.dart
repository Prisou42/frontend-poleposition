
import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  void initialize({
    required Function(String token) onVerifyEmail,
    required Function(String token) onResetPassword,
  }) {
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      final token = uri.queryParameters['token'];

      if (token == null || token.isEmpty) return;

      if (uri.host == 'verify-email') {
        onVerifyEmail(token);
      }

      if (uri.host == 'reset-password') {
        onResetPassword(token);
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
