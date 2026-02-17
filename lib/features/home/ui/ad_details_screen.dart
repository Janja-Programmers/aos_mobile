import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/routing/app_nav_config.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/app_search_bar.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/providers/ads_api_provider.dart';

import 'package:africaonlinestores/features/home/components/ad_details/ad_detail_action_buttons.dart';
import 'package:africaonlinestores/features/home/components/ad_details/ads_header_info_section.dart';
import 'package:africaonlinestores/features/home/components/ad_details/image_header_section.dart';
import 'package:africaonlinestores/features/home/components/ad_details/product_detail_section.dart';
import 'package:africaonlinestores/features/home/components/ad_details/grid_ads_section.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  const AdDetailsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  bool _loading = true;
  String? _err;

  AOSAdDetails? _ad;
  int _selectedImage = 0;

  List<AOSAdListItem> _similar = [];
  bool _loadingSimilar = false;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    final res = await ref.read(adsApiProvider).getAd(id: widget.id);
    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _loading = false;
        _err = f.message;
      }),
      (json) {
        final data = json['data'];
        final adJson = (data is Map) ? (data['item'] ?? data) : null;

        if (adJson is! Map) {
          setState(() {
            _loading = false;
            _err = 'Failed to load ad.';
          });
          return;
        }

        final ad = AOSAdDetails.fromJson(Map<String, dynamic>.from(adJson));

        // media selection clamp
        final cleanImages = ad.images
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final thumbCount = cleanImages.take(4).length;
        final hasVideo = (ad.video?.trim().isNotEmpty ?? false);
        final mediaCount = thumbCount + (hasVideo ? 1 : 0);

        setState(() {
          _ad = ad;
          _loading = false;
          _selectedImage = _selectedImage.clamp(
            0,
            (mediaCount > 0 ? mediaCount - 1 : 0),
          );
        });

        // ✅ load similar after we have the ad
        _loadSimilar();
      },
    );
  }

  Future<void> _loadSimilar() async {
    final ad = _ad;
    if (ad == null) return;
    if (_loadingSimilar) return;

    setState(() => _loadingSimilar = true);

    final categoryId = ad.categoryName;
    final countryName = ad.country;

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          countryName: countryName,
          categoryId: categoryId,
          limit: 7,
          offset: 0,
        );

    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _loadingSimilar = false;
        // optional: store error string if you want to show it
        // _similarErr = f.message;
      }),
      (json) {
        final data = json['data'];

        final raw = (data is Map)
            ? (data['items'] ?? data['results'] ?? data['list'])
            : null;

        if (raw is! List) {
          setState(() => _loadingSimilar = false);
          return;
        }

        final items = raw
            .whereType<Map>()
            .map((m) => AOSAdListItem.fromJson(Map<String, dynamic>.from(m)))
            .where((x) => x.id != widget.id)
            .take(6)
            .toList();

        setState(() {
          _similar = items;
          _loadingSimilar = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,

        leading: const BackButton(),

        title: SizedBox(
          height: 52,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: AppSearchBar(
                readOnly: true,
                controller: _searchCtrl,
                onTap: () => context.pushNamed(AppRoutes.nSearch),
                onSubmitted: (_) {},
                onMicTap: () => context.pushNamed(AppRoutes.nSearch),
                onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
              ),
            ),
          ),
        ),

        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu),
            color: context.appColors.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (index) {
              AppNavigation.goTo(context, ref, index);
            },
            itemBuilder: (context) {
              final items = AppNavConfig.items;
              final location = GoRouterState.of(context).matchedLocation;

              return List.generate(items.length, (i) {
                final item = items[i];
                final isActive = location.contains(item.routeName);
                return PopupMenuItem<int>(
                  value: i,
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.appColors.primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isActive
                              ? context.appColors.primary
                              : context.appColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: context.p.copyWith(
                            color: isActive
                                ? context.appColors.primary
                                : context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _err != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_err!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          : _ad == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ImageHeaderSection(
                        images: _ad!.images,
                        videoUrl: _ad!.video,
                        selected: _selectedImage,
                        onSelect: (i) => setState(() => _selectedImage = i),
                      ),
                      const SizedBox(height: 12),

                      AdHeaderInfoSection(
                        colorsPrimary: colors.primary,
                        locationName: _ad!.locationName,
                        country: _ad!.country,
                        title: _ad!.title,
                        priceDisplay: _ad!.priceDisplay,
                        currency: _ad!.currency,
                        price: _ad!.price,
                        priceUnit: _ad!.priceUnit,
                      ),
                      const SizedBox(height: 6),

                      AdProductDetailsSection(
                        description: _ad!.description,
                        specs: _ad!.specs,
                      ),
                      const SizedBox(height: 8),

                      if (_loadingSimilar)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        GridAdsSectionBox(
                          title: 'Similar Products',
                          items: _similar,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                AdDetailActionBar(onCall: () {}, onMessage: () {}),
              ],
            ),
    );
  }
}
