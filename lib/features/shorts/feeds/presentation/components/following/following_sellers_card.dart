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
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: colors.black.withValues(alpha: .65),
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
            seller.shopName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                  side: BorderSide(color: colors.primary),
                ),
                elevation: 0,
              ),
              child: Text('Follow', style: AppTextStylesX(context).button),
            ),
          ),
        ],
      ),
    );
  }
}
