import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/features/search/storage/search_recent_storage.dart';
import 'package:africaonlinestores/features/search/voice/voice_search_sheet.dart';
import 'package:africaonlinestores/features/search/widgets/search_bar_section.dart';
import 'package:africaonlinestores/features/search/widgets/search_header.dart';
import 'package:africaonlinestores/features/search/widgets/search_recent_section.dart';
import 'package:africaonlinestores/features/search/widgets/search_results_section.dart';

import 'package:africaonlinestores/core/files/helpers/media_helper.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  Timer? _debounce;

  bool _loading = false;
  String? _error;
  List<AOSAdListItem> _results = [];

  List<String> _recent = [];

  @override
  void initState() {
    super.initState();

    _loadRecent();
    _searchCtrl.addListener(_onSearchChanged);

    /// Wait until the first frame so context is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouter.of(context).routerDelegate.currentConfiguration.uri;

      final voiceMode = uri.queryParameters['voice'] == '1';

      if (voiceMode) {
        _openVoiceSearch();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  /// OPEN Voice search
  Future<void> _openVoiceSearch() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const VoiceSearchSheet(),
    );

    if (result == null || result.isEmpty) return;

    _searchCtrl.text = result;

    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: result.length),
    );

    unawaited(_saveRecent(result));
    unawaited(_search(result));
  }

  // CAMERA Search by image
  Future<void> _openCameraSearch() async {
    final file = await MediaHelper.pickImageWithChoice(context);

    if (file == null) return;

    _searchCtrl.text = "📷 Image search";
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchCtrl.text.length),
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ref.read(filesApiProvider).searchAdByImage(file: file);

    if (!mounted) return;

    res.fold(
      (f) {
        setState(() {
          _error = f.message;
          _results = [];
        });
      },
      (body) {
        final raw = body['data']?['items'];

        if (raw is! List) {
          setState(() => _results = []);
          return;
        }

        final list = raw
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        setState(() => _results = list);
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  /// LOAD RECENT
  Future<void> _loadRecent() async {
    final list = await SearchRecentStorage.load();

    if (!mounted) return;
    setState(() => _recent = list);
  }

  /// SAVE RECENT
  Future<void> _saveRecent(String term) async {
    await SearchRecentStorage.save(term, _recent);

    final list = await SearchRecentStorage.load();

    if (!mounted) return;
    setState(() => _recent = list);
  }

  /// DELETE ALL
  Future<void> _deleteRecent() async {
    await SearchRecentStorage.clear();

    if (!mounted) return;
    setState(() => _recent = []);
  }

  /// REMOVE ONE
  Future<void> _removeRecent(String term) async {
    await SearchRecentStorage.remove(term, _recent);

    final list = await SearchRecentStorage.load();

    if (!mounted) return;
    setState(() => _recent = list);
  }

  /// TEXT CHANGED
  void _onSearchChanged() {
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = _searchCtrl.text.trim();

      if (q.isEmpty) {
        setState(() {
          _results = [];
          _error = null;
          _loading = false;
        });
        return;
      }

      _search(q);
    });
  }

  /// API SEARCH
  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ref
        .read(adsApiProvider)
        .listAds(q: q, limit: 20, offset: 0);

    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _error = f.message;
        _results = [];
      }),
      (data) {
        final raw = data['data']?['items'];

        if (raw is! List) {
          setState(() => _results = []);
          return;
        }

        final list = raw
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        setState(() => _results = list);
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);
  }

  /// TAP RECENT
  void _setQueryAndSearch(String term) {
    _searchCtrl.text = term;

    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );

    _saveRecent(term);
    _search(term);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim();

    return Scaffold(
      appBar: const SearchHeader(),
      body: Column(
        children: [
          SearchBarSection(
            controller: _searchCtrl,
            autofocus: true,
            onSubmitted: (value) {
              final q = value.trim();

              if (q.isNotEmpty) {
                _saveRecent(q);
                _search(q);
              }
            },
            onMicTap: _openVoiceSearch,
            onCameraTap: _openCameraSearch,
          ),

          Expanded(
            child: (_results.isEmpty && query.isEmpty)
                ? SearchRecentSection(
                    recent: _recent,
                    onDeleteAll: _deleteRecent,
                    onRemoveOne: _removeRecent,
                    onPick: _setQueryAndSearch,
                  )
                : SearchResultsSection(
                    loading: _loading,
                    error: _error,
                    items: _results,
                    onTapItem: (id) {
                      context.pushNamed(
                        AppRoutes.nAdDetails,
                        pathParameters: {'id': id},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
