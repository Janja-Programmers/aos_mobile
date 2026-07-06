import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:flutter/material.dart';

class SellerBannerHeader extends StatelessWidget {
  const SellerBannerHeader({super.key, required this.seller});

  static const double _bannerHeight = 138;
  static const double _avatarRadius = 48;

  final AOSSellerProfile seller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bannerUrl = buildFileUrl(seller.shopBanner);

    return SizedBox(
      height: _bannerHeight + _avatarRadius,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            bottom: _avatarRadius,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _SellerBannerFallback(name: seller.displayName),
                  if (bannerUrl != null && bannerUrl.trim().isNotEmpty)
                    Image.network(
                      bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const SizedBox.shrink();
                      },
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.black.withValues(alpha: .12),
                          colors.black.withValues(alpha: .36),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _DisabledEditButton(
                      backgroundColor: colors.white.withValues(alpha: .92),
                      iconColor: colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _bannerHeight - _avatarRadius,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border.withValues(alpha: .7)),
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withValues(alpha: .14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AppCircularAvatar(
                name: seller.displayName,
                imageUrl: seller.avatar,
                radius: _avatarRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerBannerFallback extends StatelessWidget {
  const _SellerBannerFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: .90),
            colors.blue.withValues(alpha: .72),
            colors.black.withValues(alpha: .84),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -24,
            child: _BannerGlow(
              color: colors.white.withValues(alpha: .16),
              size: 118,
            ),
          ),
          Positioned(
            left: -34,
            bottom: -36,
            child: _BannerGlow(
              color: colors.white.withValues(alpha: .11),
              size: 136,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.h4.copyWith(
                  color: colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerGlow extends StatelessWidget {
  const _BannerGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DisabledEditButton extends StatelessWidget {
  const _DisabledEditButton({
    required this.backgroundColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: null,
      style: IconButton.styleFrom(
        disabledBackgroundColor: backgroundColor,
        disabledForegroundColor: iconColor,
      ),
      icon: const Icon(Icons.edit_rounded, size: 18),
    );
  }
}
