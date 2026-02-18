import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/social_button.dart';

class PlatformSocialSection extends StatelessWidget {
  const PlatformSocialSection({
    super.key,
    required this.loading,
    required this.onGoogle,
    required this.onApple,
    required this.googleLoading,
  });

  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final bool googleLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget dividerRow({required String label}) {
      return Row(
        children: [
          Expanded(child: Divider(color: colors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: context.p),
          ),
          Expanded(child: Divider(color: colors.border)),
        ],
      );
    }

    if (Platform.isIOS) {
      return Column(
        children: [
          const SizedBox(height: 18),
          dividerRow(label: 'Or Continue with'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SocialButton(
                  icon: SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 22,
                    height: 22,
                  ),
                  label: 'Google',
                  loading: googleLoading,
                  onPressed: onGoogle,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: SocialButton(
                  icon: SvgPicture.asset(
                    'assets/icons/apple.svg',
                    width: 22,
                    height: 22,
                  ),
                  label: 'Apple',
                  loading: googleLoading,
                  onPressed: onGoogle,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Android (and others)
    return Column(
      children: [
        const SizedBox(height: 18),
        dividerRow(label: 'Or'),
        const SizedBox(height: 14),

        SocialButton(
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 22,
            height: 22,
          ),
          label: 'Continue with Google',
          loading: googleLoading,
          onPressed: onGoogle,
        ),
      ],
    );
  }
}
