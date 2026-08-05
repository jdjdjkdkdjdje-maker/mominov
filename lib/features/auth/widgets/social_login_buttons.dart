import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';

/// Google/Apple orqali kirish tugmalari (3-band).
class SocialLoginButtons extends StatelessWidget {
  final void Function(String provider, String idToken) onToken;
  final void Function(Object error)? onError;

  const SocialLoginButtons({super.key, required this.onToken, this.onError});

  Future<void> _handleGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: AppConfig.googleClientId.isNotEmpty ? AppConfig.googleClientId : null,
        scopes: ['email'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) return; // foydalanuvchi bekor qildi
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken != null) onToken('google', idToken);
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<void> _handleApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final idToken = credential.identityToken;
      if (idToken != null) onToken('apple', idToken);
    } catch (e) {
      onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _handleGoogle,
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: const Text('Google orqali kirish'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _handleApple,
          icon: const Icon(Icons.apple_rounded, color: AppColors.ink),
          label: const Text('Apple orqali kirish'),
        ),
      ],
    );
  }
}
