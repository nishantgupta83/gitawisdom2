// lib/widgets/social_auth_buttons.dart

import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';

/// Social authentication buttons widget
/// Displays Google and Apple sign-in options
class SocialAuthButtons extends StatelessWidget {
  final SupabaseAuthService authService;

  const SocialAuthButtons({
    super.key,
    required this.authService,
  });

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final success = await authService.signInWithGoogle();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Google sign-in failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    final success = await authService.signInWithApple();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Apple sign-in failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Sign-In
        _CircularSocialButton(
          onPressed: authService.isLoading ? null : () => _handleGoogleSignIn(context),
          backgroundColor: isDark ? const Color(0xFF4285F4) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF4285F4),
          icon: Icons.g_mobiledata,
          borderColor: isDark ? null : Colors.grey.shade300,
        ),

        const SizedBox(width: 16),

        // Apple Sign-In
        _CircularSocialButton(
          onPressed: authService.isLoading ? null : () => _handleAppleSignIn(context),
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          icon: Icons.apple,
        ),
      ],
    );
  }
}

class _CircularSocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData icon;

  const _CircularSocialButton({
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = foregroundColor ?? Colors.white;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
