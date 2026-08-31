import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class ShopNowCard extends StatelessWidget {
  final Short short;
  final VoidCallback? onTap;

  const ShopNowCard({super.key, required this.short, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ad = short.ad;

    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _AdThumbnail(imageUrl: ad.thumbnail),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      style: context.p.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _formatPrice(ad.price, ad.currency),
                      style: context.p.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double? price, String? currency) {
    if (price == null || price <= 0) {
      return 'View product';
    }

    final formattedPrice = price % 1 == 0
        ? price.toInt().toString()
        : price.toStringAsFixed(2);

    final normalizedCurrency = currency?.trim();

    if (normalizedCurrency == null || normalizedCurrency.isEmpty) {
      return formattedPrice;
    }

    return '$normalizedCurrency $formattedPrice';
  }
}

class _AdThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _AdThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUri = imageUrl?.trim();
    final url = buildFileUrl(imageUri);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? _FallbackIcon()
          : AppNetworkImage(
              url: url,
              width: 42,
              height: 42,
              errorBuilder: (_, _, _) => _FallbackIcon(),
            ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Icon(Icons.shopping_bag, color: colors.primary);
  }
}
