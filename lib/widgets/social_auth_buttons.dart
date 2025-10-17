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
        // Google Sign-In with colorful logo
        _GoogleSignInButton(
          onPressed: authService.isLoading ? null : () => _handleGoogleSignIn(context),
          isDark: isDark,
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

/// Colorful Google sign-in button with official Google branding
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDark;

  const _GoogleSignInButton({
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
            child: SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: _GoogleLogoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for 4-color Google pie quadrant logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Google's official colors: Blue, Red, Yellow, Green
    // Draw 4 quadrants as a simple pie chart

    // Blue quadrant (top-right: 270° to 360°/0°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -1.5708, 1.5708, true, paint);  // -90° to 0°

    // Red quadrant (top-left: 180° to 270°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.14159, 1.5708, true, paint);  // 180° to 270°

    // Yellow quadrant (bottom-left: 90° to 180°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 1.5708, 1.5708, true, paint);  // 90° to 180°

    // Green quadrant (bottom-right: 0° to 90°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0, 1.5708, true, paint);  // 0° to 90°
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
