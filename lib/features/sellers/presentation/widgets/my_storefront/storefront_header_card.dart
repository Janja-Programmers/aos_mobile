import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';

class MyStorefrontHeaderCard extends StatelessWidget {
  const MyStorefrontHeaderCard({
    super.key,
    required this.sellerName,
    required this.avatarUrl,
    required this.isVerified,
    required this.totalAds,
    required this.totalFollowers,
    required this.rating,
    required this.totalReviews,
    required this.onCustomize,
    required this.onPreview,
  });

  final String sellerName;
  final String? avatarUrl;
  final bool isVerified;
  final int totalAds;
  final int totalFollowers;
  final double rating;
  final int totalReviews;
  final VoidCallback onCustomize;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.black.withOpacity(.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          AppCircularAvatar(name: sellerName, imageUrl: avatarUrl, radius: 42),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  sellerName,
                  style: context.h5.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                Icon(Icons.verified, color: colors.blue, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _StoreStat(value: totalAds.toString(), label: 'Posts'),
                _StoreStat(
                  value: _formatCount(totalFollowers),
                  label: 'Followers',
                ),
                _StoreStat(
                  value: rating <= 0 ? '-' : rating.toStringAsFixed(1),
                  label: totalReviews <= 0 ? 'Rating' : '$totalReviews reviews',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCustomize,
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('Customize'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text('Preview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _StoreStat extends StatelessWidget {
  const _StoreStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: context.p.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label, style: context.small, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
