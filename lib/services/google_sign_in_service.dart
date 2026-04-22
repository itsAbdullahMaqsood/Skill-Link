import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:skilllink/config/auth_config.dart';

class GoogleSignInService {
  GoogleSignInService() {
    _googleSignIn = GoogleSignIn(
      serverClientId: AuthConfig.webClientId,
      clientId: _appleClientIdIfNeeded(),
      scopes: ['email', 'profile'],
    );
  }

  static String? _appleClientIdIfNeeded() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AuthConfig.iosClientId;
      default:
        return null;
    }
  }

  late final GoogleSignIn _googleSignIn;

  Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final id = auth.idToken;
      if (id == null || id.isEmpty) {
        throw PlatformException(
          code: 'missing_id_token',
          message:
              'Google did not return an ID token. On Android, register your '
              'app SHA-1 in Google Cloud Console and set [AuthConfig.webClientId] '
              'to your Web OAuth client ID (server client ID).',
        );
      }
      return id;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
