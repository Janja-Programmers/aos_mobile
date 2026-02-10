import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/localization/utils.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';
import 'package:africaonlinestores/features/home/components/ad_card.dart';
import 'package:africaonlinestores/features/home/utils/helpers.dart';
import 'package:africaonlinestores/ui/components/app_search_bar.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

enum _ViewMode { grid, list }

/// Browse ads for a category.
///
/// - If [showPills] is true and the category has children, it shows a horizontal
///   pill bar for "All" (parent) + each child.
/// - It supports list/grid view toggle.
class AllAdsScreen extends ConsumerStatefulWidget {
  const AllAdsScreen({
    super.key,
    required this.parentCategoryId,
    this.initialCategoryId,
    this.showPills = true,
    this.bannerUrl,
  });

  /// The category id in the URL. Usually a parent category.
  final String parentCategoryId;

  /// Optional initial selected category (parent or a child).
  final String? initialCategoryId;

  /// Whether to show the pill bar.
  final bool showPills;

  /// Optional image to show at the top (e.g. parent category banner).
  final String? bannerUrl;

  @override
  ConsumerState<AllAdsScreen> createState() => _AllAdsScreenState();
}

class _AllAdsScreenState extends ConsumerState<AllAdsScreen> {
  final _searchCtrl = TextEditingController();

  final _items = <AOSAdListItem>[];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const _limit = 20;

  _ViewMode _view = _ViewMode.grid;

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = (widget.initialCategoryId ?? '').trim().isEmpty
        ? null
        : widget.initialCategoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(initial: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
      _error = null;
      if (initial) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    final categoryId = (_selectedCategoryId ?? '').trim().isEmpty
        ? widget.parentCategoryId
        : _selectedCategoryId;

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          countryName: countryName,
          categoryId: categoryId,
          limit: _limit,
          offset: _offset,
        );

    if (!mounted) return;

    res.fold((f) => setState(() => _error = f.message), (data) {
      final payload = data['data'];
      final rawItems = (payload is Map) ? payload['items'] : null;
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
    });

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
    });
  }

  void _setCategory(String? id) {
    final normalized = (id ?? '').trim();
    final next = normalized.isEmpty ? null : normalized;
    if (next == _selectedCategoryId) return;

    setState(() {
      _selectedCategoryId = next;
    });
    _refresh();
  }

  CategoryNode? _findNode(List<CategoryNode> roots, String id) {
    for (final r in roots) {
      final found = _findIn(r, id);
      if (found != null) return found;
    }
    return null;
  }

  CategoryNode? _findIn(CategoryNode node, String id) {
    if (node.id == id) return node;
    for (final c in node.children) {
      final found = _findIn(c, id);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final categoriesState = ref.watch(categoriesControllerProvider);
    final parentNode = _findNode(
      categoriesState.parents,
      widget.parentCategoryId,
    );
    final children = parentNode?.children ?? const <CategoryNode>[];
    final canShowPills = widget.showPills && children.isNotEmpty;

    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: AppSearchBar(
        controller: _searchCtrl,
        onMicTap: () {},
        onCameraTap: () {},
        onSubmitted: (_) {
          // API search wiring will be added later.
          ShowSnack(context, 'Search coming soon').info();
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(parentNode?.name ?? 'All Ads'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: searchBar,
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
            _load();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              if (widget.bannerUrl != null &&
                  widget.bannerUrl!.trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 16 / 6,
                        child: Image.network(
                          widget.bannerUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(color: scheme.surfaceContainerHighest),
                        ),
                      ),
                    ),
                  ),
                ),

              if (canShowPills)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _CategoryPills(
                      primary: scheme.primary,
                      border: scheme.outlineVariant,
                      onSurface: scheme.onSurface,
                      selectedId: _selectedCategoryId,
                      parentId: widget.parentCategoryId,
                      children: children,
                      onSelect: _setCategory,
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _showSortSheet(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Best Match',
                                style: context.pStrong.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: scheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() {
                          _view = _view == _ViewMode.grid
                              ? _ViewMode.list
                              : _ViewMode.grid;
                        }),
                        icon: Icon(
                          _view == _ViewMode.grid
                              ? Icons.view_list_outlined
                              : Icons.grid_view_outlined,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Filter', style: context.p),
                      IconButton(
                        onPressed: () => _showFilterSheet(context),
                        icon: const Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                ),
              ),

              if (_loading && _items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && _items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                _view == _ViewMode.grid
                    ? SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),
                          delegate: SliverChildBuilderDelegate((context, i) {
                            final ad = _items[i];
                            return AdCard(
                              ad: ad,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.nAdDetails, pathParameters: {'id': ad.id}),
                            );
                          }, childCount: _items.length),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList.separated(
                          itemBuilder: (context, i) {
                            final ad = _items[i];
                            return _AdListTile(
                              ad: ad,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.nAdDetails, pathParameters: {'id': ad.id}),
                            );
                          },
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemCount: _items.length,
                        ),
                      ),

              if (_loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              if (!_hasMore && _items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Center(
                      child: Text(
                        'No more results',
                        style: context.p.copyWith(color: colors.textMuted),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSortSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort By', style: context.h4),
                const SizedBox(height: 12),
                RadioListTile<int>(
                  value: 0,
                  groupValue: 0,
                  activeColor: scheme.primary,
                  onChanged: (_) => Navigator.pop(context),
                  title: const Text('Best Match'),
                ),
                RadioListTile<int>(
                  value: 1,
                  groupValue: 0,
                  activeColor: scheme.primary,
                  onChanged: (_) => Navigator.pop(context),
                  title: const Text('Price: Low to High'),
                ),
                RadioListTile<int>(
                  value: 2,
                  groupValue: 0,
                  activeColor: scheme.primary,
                  onChanged: (_) => Navigator.pop(context),
                  title: const Text('Price: High to Low'),
                ),
                RadioListTile<int>(
                  value: 3,
                  groupValue: 0,
                  activeColor: scheme.primary,
                  onChanged: (_) => Navigator.pop(context),
                  title: const Text('Newest First'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Filter', style: context.h4),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Filters UI coming soon',
                  style: context.p.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryPills extends StatelessWidget {
  const _CategoryPills({
    required this.primary,
    required this.border,
    required this.onSurface,
    required this.selectedId,
    required this.parentId,
    required this.children,
    required this.onSelect,
  });

  final Color primary;
  final Color border;
  final Color onSurface;
  final String? selectedId;
  final String parentId;
  final List<CategoryNode> children;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final pills = <_PillItem>[
      const _PillItem(id: '', label: 'All'),
      ...children.map((c) => _PillItem(id: c.id, label: c.name)),
    ];

    // Null/empty means parent ("All")
    final activeId = (selectedId ?? '').trim();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final p = pills[i];
          final isAll = p.id.isEmpty;
          final selected =
              (isAll && activeId.isEmpty) || (!isAll && p.id == activeId);
          return InkWell(
            onTap: () => onSelect(isAll ? null : p.id),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? primary : border),
              ),
              child: Center(
                child: Text(
                  p.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white : onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: pills.length,
      ),
    );
  }
}

class _PillItem {
  const _PillItem({required this.id, required this.label});
  final String id;
  final String label;
}

class _AdListTile extends StatelessWidget {
  const _AdListTile({required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final subtitle = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: ad.coverImage.isEmpty
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        toFullUrl(ad.coverImage),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: scheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    priceText(ad),
                    style: context.pStrong.copyWith(color: scheme.primary),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.p.copyWith(color: colors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.favorite_border, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
