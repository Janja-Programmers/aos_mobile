import 'dart:async';

import 'package:africaonlinestores/features/home/shared/providers/marketplace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/home/shared/providers/voice_input_controller.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';

class HomeSearchScreen extends ConsumerStatefulWidget {
  const HomeSearchScreen({super.key});

  static const String recentKey = 'home_recent_searches_v1';

  @override
  ConsumerState<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends ConsumerState<HomeSearchScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  String? _error;
  List<AOSAdListItem> _results = const [];

  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(HomeSearchScreen.recentKey) ?? const [];
    if (!mounted) return;
    setState(() => _recent = list);
  }

  Future<void> _saveRecent(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;

    final sp = await SharedPreferences.getInstance();
    final next = <String>[t, ..._recent.where((e) => e != t)];
    final trimmed = next.take(10).toList();
    await sp.setStringList(HomeSearchScreen.recentKey, trimmed);
    if (!mounted) return;
    setState(() => _recent = trimmed);
  }

  Future<void> _deleteAllRecent() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(HomeSearchScreen.recentKey);
    if (!mounted) return;
    setState(() => _recent = const []);
  }

  Future<void> _removeRecentItem(String term) async {
    final sp = await SharedPreferences.getInstance();
    final next = _recent.where((e) => e != term).toList();
    await sp.setStringList(HomeSearchScreen.recentKey, next);
    if (!mounted) return;
    setState(() => _recent = next);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _searchCtrl.text.trim();
      if (q.isEmpty) {
        setState(() {
          _error = null;
          _results = const [];
          _loading = false;
        });
        return;
      }
      _search(q);
    });
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // 🔥 Resolve market explicitly
    final market = await ref.read(marketContextProvider.future);

    final res = await ref
        .read(adsApiProvider)
        .listAds(country: market.country, q: q, limit: 20, offset: 0);

    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _error = f.message;
        _results = const [];
      }),
      (data) {
        final rawItems = data['data']?['items'];
        if (rawItems is! List) {
          setState(() => _results = const []);
          return;
        }

        final list = rawItems
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        setState(() => _results = list);
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _setQueryAndSearch(String term) {
    _searchCtrl.text = term;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchCtrl.text.length),
    );
    _saveRecent(term);
    _search(term);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final voice = ref.watch(voiceInputControllerProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: AppSearchBar(
              controller: _searchCtrl,
              autofocus: true,
              readOnly: false,
              hintText: 'Search here...',
              onSubmitted: (v) {
                final term = v.trim();
                if (term.isNotEmpty) {
                  _saveRecent(term);
                  _search(term);
                }
              },
              onMicTap: () {
                ref
                    .read(voiceInputControllerProvider.notifier)
                    .toggleListening(
                      onWords: (words, {required bool isFinal}) {
                        _searchCtrl.text = words;
                        _searchCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: words.length),
                        );
                        // Debounce listener will trigger search.
                        if (isFinal) {
                          _saveRecent(words);
                        }
                      },
                    );
              },
              onCameraTap: () => ShowSnack(context, 'Coming Soon!').info(),
            ),
          ),

          if (voice.isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Listening…',
                style: TextStyle(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          Expanded(
            child: _searchCtrl.text.trim().isEmpty
                ? _RecentSection(
                    recent: _recent,
                    onDeleteAll: _deleteAllRecent,
                    onRemoveOne: _removeRecentItem,
                    onPick: _setQueryAndSearch,
                  )
                : _ResultsSection(
                    loading: _loading,
                    error: _error,
                    items: _results,
                    onTapItem: (id) {
                      _saveRecent(_searchCtrl.text);
                      context.pushNamed(
                        AppRoutes.nAdDetails,
                        pathParameters: {'id': Uri.encodeComponent(id)},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.recent,
    required this.onDeleteAll,
    required this.onRemoveOne,
    required this.onPick,
  });

  final List<String> recent;
  final VoidCallback onDeleteAll;
  final ValueChanged<String> onRemoveOne;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
              child: Row(
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (recent.isNotEmpty)
                    TextButton(
                      onPressed: onDeleteAll,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No recent searches yet.',
                  style: TextStyle(color: colors.textMuted),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final term = recent[i];
                    return _RecentTile(
                      term: term,
                      onTap: () => onPick(term),
                      onRemove: () => onRemoveOne(term),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: colors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    term,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkResponse(
                  onTap: onRemove,
                  radius: 22,
                  child: Icon(Icons.close, size: 18, color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.loading,
    required this.error,
    required this.items,
    required this.onTapItem,
  });

  final bool loading;
  final String? error;
  final List<AOSAdListItem> items;
  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No results found.',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final ad = items[i];
        return InkWell(
          onTap: () => onTapItem(ad.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          ad.locationName,
                          ad.country,
                        ].where((e) => e.trim().isNotEmpty).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right, color: colors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}
