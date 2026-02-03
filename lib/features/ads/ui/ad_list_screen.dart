import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/ui/widgets/ad_card.dart';

class AdListScreen extends ConsumerStatefulWidget {
  const AdListScreen({super.key});

  @override
  ConsumerState<AdListScreen> createState() => _AdListScreenState();
}

class _AdListScreenState extends ConsumerState<AdListScreen> {
  final _items = <AOSAdListItem>[];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const _limit = 20;

  Future<void> _refresh() async {
    _offset = 0;
    _hasMore = true;
    _items.clear();
    await _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    if (_loading || _loadingMore) return;
    if (!_hasMore && !initial) return;

    final prefs = ref
        .read(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final country = (prefs?.countryCode ?? '').trim();
    if (country.isEmpty) {
      return;
    }

    setState(() {
      if (initial) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    final res = await ref
        .read(adsApiProvider)
        .listAds(countryCode: country, limit: _limit, offset: _offset);
    if (!mounted) return;

    res.fold(
      (f) {
        ShowSnack(context, f.message).error();
      },
      (data) {
        final raw = data['data'];
        final list = <AOSAdListItem>[];
        if (raw is Map && raw['items'] is List) {
          for (final e in (raw['items'] as List)) {
            if (e is Map) {
              list.add(AOSAdListItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }

        setState(() {
          if (_offset == 0) _items.clear();
          _items.addAll(list);
          _offset += list.length;
          _hasMore = list.length == _limit;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(initial: true));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref
        .watch(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final country = (prefs?.countryCode ?? '').trim();

    if (country.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Select your country to browse ads.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You can set it in Preferences.',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
          _load();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading && _items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Text(
                            'Popular Products',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            country,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final ad = _items[i];
                        return AdCard(
                          ad: ad,
                          onTap: () {
                            context.push(AppRoutes.adDetailsPath(ad.id));
                          },
                        );
                      }, childCount: _items.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _loadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : (!_hasMore && _items.isNotEmpty)
                          ? Text(
                              'No more ads.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
