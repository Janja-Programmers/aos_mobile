import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/following/folllowing_section_state.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';

class FollowingSellerCard extends StatelessWidget {
  final SellerSuggestion seller;
  final VoidCallback onFollowTap;
  final VoidCallback onDismiss;

  const FollowingSellerCard({
    super.key,
    required this.seller,
    required this.onFollowTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatarUrl = buildFileUrl(seller.avatar);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: colors.textMuted),
              ),
            ),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.black.withValues(alpha: .50),
            backgroundImage: avatarUrl != null
                ? AppImageDecode.networkProvider(
                    context,
                    avatarUrl,
                    logicalWidth: 60,
                    logicalHeight: 60,
                  )
                : null,
            child: avatarUrl == null
                ? Text(
                    seller.initials,
                    style: AppTextStylesX(
                      context,
                    ).button.copyWith(color: colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            seller.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.pStrong,
          ),
          const SizedBox(height: 3),
          Text(
            '${seller.totalFollowers} followers',
            style: context.pMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                minimumSize: const Size(96, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                tapTargetSize: MaterialTapTargetSize.padded,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                  side: BorderSide(color: colors.primary),
                ),
                elevation: 0,
              ),
              child: Text(
                'Follow',
                maxLines: 1,
                style: AppTextStylesX(context).button.copyWith(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
