import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_ads_provider.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/sections/seller_products_section.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_banner_header.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/store_customization/store_image_source_sheet.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyStorefrontScreen extends ConsumerStatefulWidget {
  const MyStorefrontScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<MyStorefrontScreen> createState() => _MyStorefrontScreenState();
}

class _MyStorefrontScreenState extends ConsumerState<MyStorefrontScreen> {
  bool _uploadingBanner = false;

  Future<void> _refresh() async {
    await ref.read(sellerStateProvider(widget.sellerId).notifier).load();
    ref.invalidate(sellerAdsProvider(widget.sellerId));
  }

  Future<void> _pickAndUpdateBanner() async {
    if (_uploadingBanner) return;

    final file = await showStoreImageSourceSheet(context);
    if (!mounted || file == null) return;

    setState(() => _uploadingBanner = true);

    final uploaded = await ref
        .read(mediaUploadApiProvider)
        .uploadMedia(file: file, purpose: MediaUploadPurpose.sellerBanner);

    if (!mounted) return;

    final mediaId = uploaded.fold<String?>((failure) {
      ShowSnack(context, failure.message).error();
      return null;
    }, (media) => media.mediaId);

    if (mediaId == null || mediaId.trim().isEmpty) {
      if (mounted) setState(() => _uploadingBanner = false);
      return;
    }

    final error = await ref
        .read(sellerStateProvider(widget.sellerId).notifier)
        .updateSellerProfile(shopBanner: mediaId);

    if (!mounted) return;

    setState(() => _uploadingBanner = false);

    if (error != null) {
      ShowSnack(context, error).error();
      return;
    }

    ShowSnack(context, 'Store banner updated.').success();
  }

  Future<void> _openCustomize() async {
    final changed = await SellerNavigation.toCustomizeStore(
      context,
      widget.sellerId,
    );
    if (!mounted || changed != true) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerStateProvider(widget.sellerId));
    final seller = state.seller;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'My Storefront',
          style: context.h5.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (seller == null && state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (seller == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error ?? 'Seller storefront not found.',
                  textAlign: TextAlign.center,
                  style: context.body,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _MyStorefrontHeader(
                  seller: seller,
                  uploadingBanner: _uploadingBanner,
                  onEditBanner: _pickAndUpdateBanner,
                  onCustomize: _openCustomize,
                  onPreview: () {
                    SellerNavigation.toSellerStore(
                      context,
                      widget.sellerId,
                      seller: seller,
                    );
                  },
                ),
                const SizedBox(height: 14),
                SellerProductsSection(sellerId: widget.sellerId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyStorefrontHeader extends StatelessWidget {
  const _MyStorefrontHeader({
    required this.seller,
    required this.uploadingBanner,
    required this.onEditBanner,
    required this.onCustomize,
    required this.onPreview,
  });

  final AOSSellerProfile seller;
  final bool uploadingBanner;
  final VoidCallback onEditBanner;
  final VoidCallback onCustomize;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SectionCard(
      child: Column(
        children: [
          Stack(
            children: [
              SellerBannerHeader(seller: seller, onEditBanner: onEditBanner),
              if (uploadingBanner)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.black.withValues(alpha: .22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  seller.displayName,
                  style: context.h5.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (seller.isVerified) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(),
              ],
            ],
          ),
          if (seller.businessCategory?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              seller.businessCategory!,
              style: context.pMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.surface,
              border: Border.all(color: colors.border.withValues(alpha: .6)),
            ),
            child: Row(
              children: [
                _StoreStat(value: seller.ratingLabel, label: 'Rating'),
                _divider(colors),
                _StoreStat(value: seller.followersLabel, label: 'Followers'),
                _divider(colors),
                _StoreStat(
                  value: seller.joined.trim().isEmpty ? '—' : seller.joined,
                  label: 'Joined',
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
                  icon: const Icon(Icons.tune_rounded, size: 18),
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
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.pStrong.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: context.smallMuted, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

Widget _divider(AppColorTokens colors) {
  return Container(width: 1, height: 34, color: colors.border);
}
