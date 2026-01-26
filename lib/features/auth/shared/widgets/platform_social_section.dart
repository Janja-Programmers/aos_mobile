import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aos_mobile/core/theme/app_theme_extensions.dart';
import 'package:aos_mobile/ui/components/buttons/social_button.dart';

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

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    Widget dividerRow({required String label}) {
      return Row(
        children: [
          Expanded(child: Divider(color: colors.stroke)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: TextStyle(color: colors.muted)),
          ),
          Expanded(child: Divider(color: colors.stroke)),
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
              SocialButton(
                icon: SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 22,
                  height: 22,
                ),
                text: loading ? 'Google' : 'Continue with Google',
                onTap: loading ? null : onGoogle,
              ),
              const SizedBox(width: 12),
              SocialButton(
                icon: SvgPicture.asset(
                  'assets/icons/apple.svg',
                  width: 22,
                  height: 22,
                ),
                text: loading ? 'Apple' : 'Continue with Apple',
                onTap: loading ? null : onApple,
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
        SizedBox(
          height: 54,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: loading ? null : onGoogle,
            icon: googleLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.onSurface,
                      ),
                    ),
                  )
                : SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 22,
                    height: 22,
                  ),
            label: Text(
              googleLoading ? 'Signing in…' : 'Continue with Google',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              side: BorderSide(color: colors.stroke),
              shape: const RoundedRectangleBorder(borderRadius: _pill),
            ),
          ),
        ),
      ],
    );
  }
}
