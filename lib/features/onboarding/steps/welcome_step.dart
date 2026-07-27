import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final landscape = media.orientation == Orientation.landscape;

    return ColoredBox(
      color: colors.surface,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _TopInnerCurveClipper(),
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: media.size.height * (landscape ? 0.82 : 0.62),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          colors.white.withValues(alpha: 0.92),
                          colors.white,
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            l10n.account_guest_title,
                            style: context.h3.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.account_guest_description,
                            style: context.pMuted.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: l10n.common_get_started,
                            onPressed: onContinue,
                          ),
                        ],
                      ),
                    ),
                  ),
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
    return Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
