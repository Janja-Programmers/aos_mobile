import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/auth/shared/widgets/google_button.dart';

class PlatformSocialSection extends StatelessWidget {
  const PlatformSocialSection({
    super.key,
    required this.loading,
    required this.onGoogle,
    required this.onApple,
    required this.googleLoading,
    required this.appleLoading,
  });

  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final bool googleLoading;
  final bool appleLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final isIOS = Platform.isIOS;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),

        dividerRow(label: l10n.auth_or),
        const SizedBox(height: 14),

        /// GOOGLE
        GoogleButton(
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 22,
            height: 22,
          ),
          label: isIOS ? "Sign in with Google" :l10n.auth_continue_google,
          loading: googleLoading,
          onPressed: loading ? null : onGoogle,
        ),

        const SizedBox(height: 12),

        /// APPLE (iOS only)
        if (isIOS)
          SizedBox(
            height: 54,
            child: appleLoading
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : SignInWithAppleButton(
                    onPressed: loading ? null : onApple,
                  ),
          ),
      ],
    );
  }
}
