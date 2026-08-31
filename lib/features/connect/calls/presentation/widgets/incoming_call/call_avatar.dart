import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class CallAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallback;

  const CallAvatar({super.key, this.avatarUrl, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 146,
      height: 146,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        border: Border.all(color: colors.primary, width: 5),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: .15),
            blurRadius: 26,
            spreadRadius: 10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: AppNetworkImage(url: avatarUrl!, width: 146, height: 146),
            )
          : Center(
              child: Text(
                fallback.substring(0, 1).toUpperCase(),
                style: context.body.copyWith(
                  fontSize: 58,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
