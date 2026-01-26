import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aos_mobile/core/theme/app_colors.dart';
import 'package:aos_mobile/core/theme/app_theme.dart';

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
    if (Platform.isIOS) {
      return Column(
        children: [
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.stroke)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Or Continue with',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              Expanded(child: Divider(color: AppColors.stroke)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTheme.socialButton(
                  icon: SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 22,
                    height: 22,
                  ),
                  text: 'Google',
                  onTap: loading ? null : onGoogle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTheme.socialButton(
                  icon: SvgPicture.asset(
                    'assets/icons/apple.svg',
                    width: 22,
                    height: 22,
                  ),
                  text: 'Apple',
                  onTap: loading ? null : onApple,
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
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.stroke)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Or', style: TextStyle(color: AppColors.muted)),
            ),
            Expanded(child: Divider(color: AppColors.stroke)),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: loading ? null : onGoogle,
            icon: googleLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: AppColors.stroke),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
