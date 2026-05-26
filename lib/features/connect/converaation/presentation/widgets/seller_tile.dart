import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';

class SellerTile extends StatelessWidget {
  const SellerTile({
    super.key,
    required this.seller,
    required this.onTap,
    this.trailing,
  });

  final SellerListItem seller;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatorUrl = buildFileUrl(seller.avatar);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: colors.border,
        backgroundImage: seller.avatar != null
            ? NetworkImage(avatorUrl!)
            : null,
        child: seller.avatar == null
            ? Text(
                _initials(seller.shopName),
                style: context.body.copyWith(fontWeight: FontWeight.w700),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              seller.seller,
              style: context.body.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (seller.isVerified) ...[
            const SizedBox(width: 4),
            Icon(Icons.verified, size: 16, color: colors.blue),
          ],
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seller.displayCategory,
              style: AppTextStylesX(
                context,
              ).caption.copyWith(color: colors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              seller.displayLocation,
              style: AppTextStylesX(
                context,
              ).caption.copyWith(color: colors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      trailing: trailing ?? _SellerRatingSummary(seller: seller),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _SellerRatingSummary extends StatelessWidget {
  const _SellerRatingSummary({required this.seller});

  final SellerListItem seller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 16, color: colors.amber),
            const SizedBox(width: 2),
            Text(
              seller.rating.toStringAsFixed(1),
              style: context.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${seller.totalReviews} reviews',
          style: AppTextStylesX(
            context,
          ).caption.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
