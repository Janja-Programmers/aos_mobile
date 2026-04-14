import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/chats/presentation/screens/new_message_screen.dart';

class SellerTile extends StatelessWidget {
  final Seller seller;
  final VoidCallback onTap;

  const SellerTile({super.key, required this.seller, required this.onTap});

  bool get hasAvatar => seller.avatar != null && seller.avatar!.isNotEmpty;

  Color _avatarColor(BuildContext context) {
    final appColors = context.appColors;

    final colors = [
      appColors.red,
      appColors.success,
      appColors.amber,
      appColors.chatCardColor,
    ];
    return colors[seller.shopName.hashCode % colors.length];
  }

  String _formatReviews(int count) {
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K reviews";
    }
    return "$count reviews";
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,

      // 🔥 AVATAR
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: hasAvatar
                ? Colors.grey.shade200
                : _avatarColor(context),
            backgroundImage: hasAvatar ? NetworkImage(seller.avatar!) : null,
            child: !hasAvatar
                ? Text(
                    seller.shopName[0],
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),

          // 🟢 ONLINE DOT
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: seller.isOnline ? colors.success : colors.border,
                shape: BoxShape.circle,
                border: Border.all(color: colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),

      // 🔥 TITLE + VERIFIED
      title: Row(
        children: [
          Expanded(
            child: Text(
              seller.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          if (seller.isVerified)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(Icons.verified, color: colors.blue, size: 16),
            ),
        ],
      ),

      // 🔥 SUBTITLE
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seller.category,
            style: context.p.copyWith(overflow: TextOverflow.ellipsis),
          ),

          const SizedBox(height: 2),

          Row(
            children: [
              const Icon(Icons.location_on, size: 12),
              const SizedBox(width: 2),

              Expanded(
                child: Text(
                  seller.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.pMuted,
                ),
              ),
            ],
          ),
        ],
      ),

      // ⭐ RATING
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: colors.amber, size: 16),
              const SizedBox(width: 2),

              Text(
                seller.rating.toStringAsFixed(1),
                style: context.p.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            _formatReviews(seller.totalReviews),
            style: context.p.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
