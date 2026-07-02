import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/welcome.png', fit: BoxFit.cover),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _TopInnerCurveClipper(),
              child: Container(
                width: double.infinity,
                height: 280,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.white.withValues(alpha: 0.92),
                      colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.account_guest_title,
                      style: context.h3.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.account_guest_description,
                      style: context.pMuted.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      text: l10n.common_get_started,
                      onPressed: onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopInnerCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 40.0;

    final path = Path();

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
