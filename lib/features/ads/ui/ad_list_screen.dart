import 'package:africaonlinestores/core/localization/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/ui/sections/ads_content.dart';
import 'package:africaonlinestores/features/ads/ui/sections/ads_empty.dart';
import 'package:africaonlinestores/features/ads/ui/sections/ads_error.dart';
import 'package:africaonlinestores/features/ads/ui/sections/ads_loading.dart';

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
  String? _error;
  int _offset = 0;
  static const _limit = 20;

  Future<void> _refresh() async {
    _offset = 0;
    _hasMore = true;
    _error = null;
    _items.clear();
    await _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    if (_loading || _loadingMore) return;
    if (!_hasMore && !initial) return;

    final prefs = ref
        .read(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    final codeOrLabel = (prefs?.countryCode ?? '').trim();
    if (codeOrLabel.isEmpty) return;

    // Backend expects a country NAME for list_ads
    const fallbackCountryName = 'Kenya';
    String countryName = fallbackCountryName;

    try {
      final bundle = await ref.read(localeBundleProvider.future);
      countryName =
          labelFor(bundle.countries, codeOrLabel) ?? fallbackCountryName;
    } catch (_) {
      countryName = fallbackCountryName;
    }

    if (countryName.trim().isEmpty) return;

    setState(() {
      if (initial) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    final res = await ref
        .read(adsApiProvider)
        .listAds(countryName: countryName, limit: _limit, offset: _offset);
    if (!mounted) return;

    res.fold(
      (f) {
        setState(() => _error = f.message);
      },
      (data) {
        final payload = data['data'];
        final rawItems = payload['items'];

        if (rawItems is! List) return;

        final list = rawItems
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(initial: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localeControllerProvider, (_, _) => _refresh());

    final prefs = ref
        .watch(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final country = (prefs?.countryCode ?? '').trim();

    if (_loading && _items.isEmpty) {
      return const AdListLoadingView();
    }

    if (_error != null && _items.isEmpty) {
      return AdListErrorView(message: _error!, onRetry: _refresh);
    }

    if (!_loading && _items.isEmpty) {
      return AdListEmptyView(onRefresh: _refresh);
    }

    return AdListContentView(
      items: _items,
      country: country,
      onLoadMore: _load,
      onRefresh: _refresh,
      loadingMore: _loadingMore,
      hasMore: _hasMore,
    );
  }
}
