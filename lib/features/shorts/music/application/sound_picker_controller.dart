import 'dart:async';

import 'package:africaonlinestores/features/shorts/music/data/shorts_sounds_api.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';

class SoundPickerState extends Equatable {
  const SoundPickerState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.query,
    required this.sourceType,
    required this.showFavorites,
    this.nextCursor,
    this.playingSoundId,
    this.errorMessage,
  });

  factory SoundPickerState.initial() => const SoundPickerState(
    items: <ShortSound>[ShortSound.original],
    isLoading: false,
    isLoadingMore: false,
    hasMore: false,
    query: '',
    sourceType: 'all',
    showFavorites: false,
  );

  final List<ShortSound> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final String sourceType;
  final bool showFavorites;
  final String? nextCursor;
  final String? playingSoundId;
  final String? errorMessage;

  SoundPickerState copyWith({
    List<ShortSound>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    String? sourceType,
    bool? showFavorites,
    String? nextCursor,
    String? playingSoundId,
    String? errorMessage,
    bool clearCursor = false,
    bool clearPlaying = false,
    bool clearError = false,
  }) {
    return SoundPickerState(
      items: items == null ? this.items : List<ShortSound>.unmodifiable(items),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      sourceType: sourceType ?? this.sourceType,
      showFavorites: showFavorites ?? this.showFavorites,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      playingSoundId: clearPlaying
          ? null
          : playingSoundId ?? this.playingSoundId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    items,
    isLoading,
    isLoadingMore,
    hasMore,
    query,
    sourceType,
    showFavorites,
    nextCursor,
    playingSoundId,
    errorMessage,
  ];
}

class SoundPickerController extends StateNotifier<SoundPickerState> {
  SoundPickerController(this._api)
    : _player = AudioPlayer(),
      super(SoundPickerState.initial()) {
    _completionSubscription = _player.playerStateStream.listen((
      PlayerState value,
    ) {
      if (value.processingState == ProcessingState.completed && !_disposed) {
        state = state.copyWith(clearPlaying: true);
      }
    });
  }

  final ShortsSoundsApi _api;
  final AudioPlayer _player;
  final Set<String> _favoriteOperations = <String>{};
  StreamSubscription<PlayerState>? _completionSubscription;
  Timer? _debounce;
  int _requestGeneration = 0;
  int _previewGeneration = 0;
  bool _disposed = false;

  Future<void> initialize({bool commercialSafeOnly = false}) {
    return _loadFirst(commercialSafeOnly: commercialSafeOnly);
  }

  Future<void> retry({bool commercialSafeOnly = false}) {
    return _loadFirst(commercialSafeOnly: commercialSafeOnly);
  }

  Future<void> setSourceType(
    String sourceType, {
    bool commercialSafeOnly = false,
  }) async {
    if (sourceType == state.sourceType && !state.showFavorites) return;
    state = state.copyWith(sourceType: sourceType, showFavorites: false);
    await _loadFirst(commercialSafeOnly: commercialSafeOnly);
  }

  Future<void> setFavorites(
    bool value, {
    bool commercialSafeOnly = false,
  }) async {
    if (value == state.showFavorites) return;
    state = state.copyWith(showFavorites: value);
    await _loadFirst(commercialSafeOnly: commercialSafeOnly);
  }

  void search(String value, {bool commercialSafeOnly = false}) {
    final clean = value.trim();
    final generation = ++_requestGeneration;
    state = state.copyWith(query: clean);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (clean.isEmpty) {
        unawaited(
          _loadFirst(
            commercialSafeOnly: commercialSafeOnly,
            generation: generation,
          ),
        );
      } else {
        unawaited(
          _search(
            clean,
            commercialSafeOnly: commercialSafeOnly,
            generation: generation,
          ),
        );
      }
    });
  }

  Future<void> loadMore({bool commercialSafeOnly = false}) async {
    if (state.isLoadingMore ||
        state.isLoading ||
        !state.hasMore ||
        state.nextCursor == null ||
        state.query.isNotEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    final generation = _requestGeneration;
    final result = state.showFavorites
        ? await _api.myFavoriteSounds(cursor: state.nextCursor)
        : await _api.listSounds(
            cursor: state.nextCursor,
            sourceType: state.sourceType,
          );
    if (_disposed || generation != _requestGeneration) return;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (page) {
        final merged = <String, ShortSound>{
          for (final item in state.items) item.id: item,
          for (final item in _filtered(page.items, commercialSafeOnly))
            item.id: item,
        };
        state = state.copyWith(
          items: merged.values.toList(growable: false),
          isLoadingMore: false,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );
      },
    );
  }

  Future<void> togglePreview(ShortSound sound) async {
    if (!sound.isPlayable || _disposed) return;
    final generation = ++_previewGeneration;
    if (state.playingSoundId == sound.id) {
      await _player.stop();
      if (!_disposed && generation == _previewGeneration) {
        state = state.copyWith(clearPlaying: true);
      }
      return;
    }

    try {
      await _player.stop();
      if (_disposed || generation != _previewGeneration) return;
      await _player.setUrl(sound.fileUrl!);
      if (_disposed || generation != _previewGeneration) return;
      state = state.copyWith(playingSoundId: sound.id, clearError: true);
      await _player.play();
    } catch (_) {
      if (!_disposed && generation == _previewGeneration) {
        state = state.copyWith(
          clearPlaying: true,
          errorMessage: 'Could not preview this sound.',
        );
      }
    }
  }

  Future<void> toggleFavorite(ShortSound sound) async {
    if (sound.isOriginal || _disposed || !_favoriteOperations.add(sound.id)) {
      return;
    }
    try {
      final result = await _api.favoriteSound(soundId: sound.id);
      if (_disposed) return;
      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (favorite) {
          final items = state.items
              .map((ShortSound item) {
                if (item.id != sound.id) return item;
                return item.copyWith(
                  isFavorite: favorite.favorited,
                  favoriteCount: favorite.favoriteCount,
                  favoriteCountDisplay: favorite.favoriteCountDisplay,
                );
              })
              .toList(growable: false);
          state = state.copyWith(items: items, clearError: true);
        },
      );
    } finally {
      _favoriteOperations.remove(sound.id);
    }
  }

  Future<void> _loadFirst({
    required bool commercialSafeOnly,
    int? generation,
  }) async {
    final currentGeneration = generation ?? ++_requestGeneration;
    if (currentGeneration != _requestGeneration || _disposed) return;
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      items: const <ShortSound>[ShortSound.original],
      clearCursor: true,
      hasMore: false,
      clearError: true,
    );
    final result = state.showFavorites
        ? await _api.myFavoriteSounds()
        : await _api.listSounds(sourceType: state.sourceType);
    if (_disposed || currentGeneration != _requestGeneration) return;
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (page) {
        state = state.copyWith(
          items: <ShortSound>[
            ShortSound.original,
            ..._filtered(page.items, commercialSafeOnly),
          ],
          isLoading: false,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );
      },
    );
  }

  Future<void> _search(
    String query, {
    required bool commercialSafeOnly,
    required int generation,
  }) async {
    if (_disposed || generation != _requestGeneration) return;
    state = state.copyWith(
      isLoading: true,
      items: const <ShortSound>[ShortSound.original],
      hasMore: false,
      clearCursor: true,
      clearError: true,
    );
    final result = await _api.searchSounds(query: query, limit: 30);
    if (_disposed || generation != _requestGeneration) return;
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (items) {
        state = state.copyWith(
          items: <ShortSound>[
            ShortSound.original,
            ..._filtered(items, commercialSafeOnly),
          ],
          isLoading: false,
        );
      },
    );
  }

  List<ShortSound> _filtered(List<ShortSound> items, bool commercialOnly) {
    if (!commercialOnly) return items;
    return items
        .where((ShortSound item) => item.isCommercialSafe)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _disposed = true;
    _requestGeneration++;
    _previewGeneration++;
    _debounce?.cancel();
    unawaited(_completionSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
