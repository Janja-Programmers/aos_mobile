import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
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
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _StoreBannerAction { change, remove }

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

  Future<void> _showBannerActions() async {
    if (_uploadingBanner) return;

    final seller = ref.read(sellerStateProvider(widget.sellerId)).seller;
    final hasBanner = seller?.shopBanner?.trim().isNotEmpty ?? false;
    if (!hasBanner) {
      await _pickAndUpdateBanner();
      return;
    }

    final action = await showDialog<_StoreBannerAction>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;
        return Dialog(
          backgroundColor: colors.surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Store banner',
                            style: dialogContext.h5.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            dialogContext,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.photo_library_outlined,
                        color: colors.primary,
                      ),
                      title: Text(dialogContext.l10n.sellerBannerChangeAction),
                      onTap: () => Navigator.pop(
                        dialogContext,
                        _StoreBannerAction.change,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.primary,
                      ),
                      title: Text(dialogContext.l10n.sellerBannerRemoveAction),
                      onTap: () => Navigator.pop(
                        dialogContext,
                        _StoreBannerAction.remove,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _StoreBannerAction.change:
        await _pickAndUpdateBanner();
        break;
      case _StoreBannerAction.remove:
        await _removeBanner();
        break;
    }
  }

  Future<void> _removeBanner() async {
    if (_uploadingBanner) return;
    setState(() => _uploadingBanner = true);

    final error = await ref
        .read(sellerStateProvider(widget.sellerId).notifier)
        .updateSellerProfile(clearShopBanner: true);

    if (!mounted) return;
    setState(() => _uploadingBanner = false);

    if (error != null) {
      ShowSnack(context, error).error();
      return;
    }
    ShowSnack(context, context.l10n.sellerBannerRemoved).success();
  }

  Future<void> _pickAndUpdateBanner() async {
    if (_uploadingBanner) return;

    final media = await showStoreImageSourceSheet(context, ref: ref);
    if (media == null) return;
    if (!mounted) {
      await media.discard();
      return;
    }

    setState(() => _uploadingBanner = true);

    final uploadCoordinator = ref.read(mediaUploadCoordinatorProvider);
    final mediaUploadApi = ref.read(mediaUploadApiProvider);
    final uploaded = await uploadCoordinator.upload(
      media: media,
      useCase: MediaUseCase.sellerBanner,
    );
    await media.discard();

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
      unawaited(mediaUploadApi.deleteMedia(mediaId: mediaId));
      ShowSnack(context, error).error();
      return;
    }

    ShowSnack(context, context.l10n.sellerBannerUpdated).success();
  }

  Future<void> _openCustomize() async {
    final changed = await SellerNavigation.toCustomizeStore(
      context,
      widget.sellerId,
    );
    if (!mounted || changed != true) return;
    await _refresh();
  }

  Future<void> _openLocation() async {
    final changed = await SellerNavigation.toSellerLocation(context);
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
                  onEditBanner: _showBannerActions,
                  onCustomize: _openCustomize,
                  onLocation: _openLocation,
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
    required this.onLocation,
    required this.onPreview,
  });

  final AOSSellerProfile seller;
  final bool uploadingBanner;
  final VoidCallback onEditBanner;
  final VoidCallback onCustomize;
  final VoidCallback onLocation;
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
                child: OutlinedButton(
                  onPressed: onCustomize,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Customize', maxLines: 1, softWrap: false),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: onPreview,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Preview', maxLines: 1, softWrap: false),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: onLocation,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Location', maxLines: 1, softWrap: false),
                  ),
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
