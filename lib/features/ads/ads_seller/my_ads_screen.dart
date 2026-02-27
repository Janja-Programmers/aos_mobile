import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/shared/ui/sections/my_ads_content.dart';
import 'package:africaonlinestores/features/ads/shared/ui/sections/my_ads_empty.dart';
import 'package:africaonlinestores/features/ads/shared/ui/sections/my_ads_error.dart';
import 'package:africaonlinestores/features/ads/shared/ui/sections/my_ads_loading.dart';
import 'package:africaonlinestores/features/ads/shared/ui/sections/my_ads_tabs.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  String _status = 'Active';
  bool _loading = false;
  String? _error;
  List<AOSAdListItem> _items = const [];

  Map<String, int> _counts = const {};

  String _apiStatusForTab(String tab) => tab == 'Drafts' ? 'Draft' : tab;

  String _tabKeyForStatus(String apiStatus) =>
      apiStatus == 'Draft' ? 'Drafts' : apiStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // =======================
  // EMPTY STATE HELPERS
  // =======================

  String _emptyTitle() {
    switch (_status) {
      case 'Draft':
        return 'No Drafts Yet';
      case 'Reviewing':
        return 'Nothing Under Review';
      case 'Declined':
        return 'No Declined Ads';
      case 'Active':
      default:
        return 'No Listings Yet';
    }
  }

  String _emptyDescription() {
    switch (_status) {
      case 'Draft':
        return 'You have no saved drafts.';
      case 'Reviewing':
        return 'You have no ads currently under review.';
      case 'Declined':
        return 'You have no declined ads at the moment.';
      case 'Active':
      default:
        return "You haven't posted any ads yet.\nStart selling by creating your first listing!";
    }
  }

  String _emptyPrimaryLabel() {
    switch (_status) {
      case 'Draft':
        return 'Create An Ad';
      case 'Reviewing':
        return 'Create An Ad';
      case 'Declined':
        return 'Create An Ad';
      case 'Active':
      default:
        return 'Post Your First Ad';
    }
  }

  // =======================
  // LOAD DATA
  // =======================

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final statuses = {
      'Active': 'Active',
      'Reviewing': 'Reviewing',
      'Drafts': 'Draft',
      'Declined': 'Declined',
    };

    final Map<String, int> newCounts = {};

    // Load counts for all tabs
    for (final entry in statuses.entries) {
      final res = await ref.read(adsApiProvider).myAds(status: entry.value);

      if (!mounted) return;

      res.fold((_) => newCounts[entry.key] = 0, (data) {
        final dataMap = (data['data'] ?? const {}) as Map;

        final pagination = (dataMap['pagination'] ?? const {}) as Map;

        final totalRaw = pagination['total'];
        final total = totalRaw is int
            ? totalRaw
            : int.tryParse('$totalRaw') ?? 0;

        newCounts[entry.key] = total;
      });
    }

    // Load current tab items
    final res = await ref.read(adsApiProvider).myAds(status: _status);

    if (!mounted) return;

    res.fold(
      (f) {
        setState(() {
          _loading = false;
          _error = f.message;
          _items = const [];
          _counts = newCounts;
        });
      },
      (data) {
        final dataMap = (data['data'] ?? const {}) as Map;

        final itemsRaw = dataMap['items'];
        final list = <AOSAdListItem>[];

        if (itemsRaw is List) {
          for (final e in itemsRaw) {
            if (e is Map) {
              list.add(AOSAdListItem.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }

        setState(() {
          _loading = false;
          _error = null;
          _items = list;
          _counts = newCounts;
        });
      },
    );
  }

  // =======================
  // BUILD
  // =======================

  @override
  Widget build(BuildContext context) {
    final tabs = const ['Active', 'Reviewing', 'Drafts', 'Declined'];

    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: scheme.surface,

      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text('My Listings', style: context.h4),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          MyAdsTabs(
            tabs: tabs,
            selected: _tabKeyForStatus(_status),
            counts: _counts,
            onChanged: (tabLabel) {
              setState(() => _status = _apiStatusForTab(tabLabel));
              _load();
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _loading
                ? const MyAdsLoadingView()
                : (_error != null)
                ? MyAdsErrorView(message: _error!, onRetry: _load)
                : (_items.isEmpty)
                ? MyAdsEmptyView(
                    title: _emptyTitle(),
                    primaryLabel: _emptyPrimaryLabel(),
                    description: _emptyDescription(),
                    onPrimaryAction: () {
                      context.pushNamed(AppRoutes.nCreateAd);
                    },
                    onLearnMore: () {
                      ShowSnack(context, 'Guide coming soon.').info();
                    },
                  )
                : MyAdsContentView(
                    items: _items,
                    onEdit: (ad) =>
                        ShowSnack(context, 'Edit coming soon.').info(),
                    onMarkSold: (ad) =>
                        ShowSnack(context, 'Status update coming soon.').info(),
                  ),
          ),
        ],
      ),

      // ✅ Minimal + FAB
      floatingActionButton: (!_loading && _error == null && _items.isNotEmpty)
          ? FloatingActionButton(
              backgroundColor: colors.primary,
              onPressed: () => context.pushNamed(AppRoutes.nCreateAd),
              child: Icon(Icons.add, color: colors.border),
            )
          : null,
    );
  }
}
