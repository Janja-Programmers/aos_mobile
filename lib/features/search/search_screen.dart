import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/features/search/storage/search_recent_storage.dart';
import 'package:africaonlinestores/features/search/voice/voice_search_sheet.dart';
import 'package:africaonlinestores/features/search/widgets/image_search_sheet.dart';
import 'package:africaonlinestores/features/search/widgets/search_bar_section.dart';
import 'package:africaonlinestores/features/search/widgets/search_header.dart';
import 'package:africaonlinestores/features/search/widgets/search_recent_section.dart';
import 'package:africaonlinestores/features/search/widgets/search_results_section.dart';

enum SearchStatus { idle, loading, empty, error, data }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialMode = 'text'});

  final String initialMode;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();

  Timer? _debounce;

  SearchStatus _status = SearchStatus.idle;
  String? _error;
  List<AOSAdListItem> _results = [];
  List<String> _recent = [];

  String? _visualSearchTitle;
  String? _visualSearchSubtitle;
  bool _handledInitialMode = false;

  bool get _loading => _status == SearchStatus.loading;

  @override
  void initState() {
    super.initState();

    _loadRecent();
    _searchCtrl.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handledInitialMode) return;

      _handledInitialMode = true;

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      switch (widget.initialMode) {
        case 'voice':
          await _openVoiceSearch();
          break;

        case 'image':
          await _openCameraSearch();
          break;

        case 'text':
        default:
          break;
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

  Future<void> _openVoiceSearch() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const VoiceSearchSheet(),
    );

    if (result == null || result.trim().isEmpty) return;

    final q = result.trim();

    _searchCtrl.text = q;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );

    unawaited(_saveRecent(q));
    unawaited(_search(q));
  }

  Future<void> _openCameraSearch() async {
    appLogger.i('IMAGE SEARCH SHEET OPENING');

    final file = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImageSearchSheet(),
    );

    appLogger.i('IMAGE SEARCH SHEET CLOSED: $file');

    if (file == null) return;
    _debounce?.cancel();

    setState(() {
      _status = SearchStatus.loading;
      _error = null;
      _results = [];
      _visualSearchTitle = 'Visual Search';
      _visualSearchSubtitle = 'Searching similar products...';
    });

    final res = await ref.read(filesApiProvider).searchAdByImage(file: file);

    if (!mounted) return;

    res.fold(
      (f) {
        setState(() {
          _status = SearchStatus.error;
          _error = f.message;
          _results = [];
          _visualSearchSubtitle = null;
        });
      },
      (body) {
        final raw = body['data']?['items'];

        final list = raw is List
            ? raw
                  .whereType<Map<String, dynamic>>()
                  .map(AOSAdListItem.fromJson)
                  .toList()
            : <AOSAdListItem>[];

        setState(() {
          _results = list;
          _error = null;
          _status = list.isEmpty ? SearchStatus.empty : SearchStatus.data;
          _visualSearchSubtitle = '${list.length} similar products found';
        });
      },
    );
  }

  Future<void> _loadRecent() async {
    final list = await SearchRecentStorage.load();

    if (!mounted) return;
    setState(() => _recent = list);
  }

  Future<void> _saveRecent(String term) async {
    await SearchRecentStorage.save(term, _recent);

    final list = await SearchRecentStorage.load();

    if (!mounted) return;
    setState(() => _recent = list);
  }

  Future<void> _deleteRecent() async {
    await SearchRecentStorage.clear();

    if (!mounted) return;
    setState(() => _recent = []);
  }

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
          _status = SearchStatus.idle;
          _error = null;
          _results = [];
          _visualSearchTitle = null;
          _visualSearchSubtitle = null;
        });
        return;
      }

      _search(q);
    });
  }

  /// API SEARCH
  Future<void> _search(String q) async {
    setState(() {
      _status = SearchStatus.loading;
      _error = null;
      _results = [];
      _visualSearchTitle = null;
      _visualSearchSubtitle = null;
    });

    final res = await ref
        .read(adsApiProvider)
        .listAds(q: q, limit: 20, offset: 0);

    if (!mounted) return;

    res.fold(
      (f) {
        setState(() {
          _status = SearchStatus.error;
          _error = f.message;
          _results = [];
        });
      },
      (data) {
        final raw = data['data']?['items'];

        final list = raw is List
            ? raw
                  .whereType<Map<String, dynamic>>()
                  .map(AOSAdListItem.fromJson)
                  .toList()
            : <AOSAdListItem>[];

        setState(() {
          _results = list;
          _error = null;
          _status = list.isEmpty ? SearchStatus.empty : SearchStatus.data;
        });
      },
    );
  }

  /// TAP RECENT
  void _setQueryAndSearch(String term) {
    final q = term.trim();

    if (q.isEmpty) return;

    _searchCtrl.text = q;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );

    unawaited(_saveRecent(q));
    unawaited(_search(q));
  }

  void _clearVisualSearch() {
    setState(() {
      _status = SearchStatus.idle;
      _error = null;
      _results = [];
      _visualSearchTitle = null;
      _visualSearchSubtitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showRecent = _status == SearchStatus.idle;

    return Scaffold(
      appBar: const SearchHeader(),
      body: Column(
        children: [
          SearchBarSection(
            controller: _searchCtrl,
            autofocus: widget.initialMode == 'text',
            onSubmitted: (value) {
              final q = value.trim();

              if (q.isEmpty) return;

              unawaited(_saveRecent(q));
              unawaited(_search(q));
            },
            onMicTap: _openVoiceSearch,
            onCameraTap: _openCameraSearch,
          ),

          Expanded(
            child: showRecent
                ? SearchRecentSection(
                    recent: _recent,
                    onDeleteAll: _deleteRecent,
                    onRemoveOne: _removeRecent,
                    onPick: _setQueryAndSearch,
                  )
                : SearchResultsSection(
                    loading: _loading,
                    error: _status == SearchStatus.error ? _error : null,
                    items: _results,
                    visualSearchTitle: _visualSearchTitle,
                    visualSearchSubtitle: _visualSearchSubtitle,
                    onClearVisualSearch: _visualSearchTitle == null
                        ? null
                        : _clearVisualSearch,
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
