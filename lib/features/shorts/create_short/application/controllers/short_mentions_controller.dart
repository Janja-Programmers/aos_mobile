import 'dart:async';

import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

class ShortMentionsState extends Equatable {
  const ShortMentionsState({
    required this.query,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.nextStart,
    this.errorMessage,
  });

  factory ShortMentionsState.initial() => const ShortMentionsState(
    query: '',
    items: <SocialFriend>[],
    isLoading: false,
    isLoadingMore: false,
    hasMore: false,
    nextStart: 0,
  );

  final String query;
  final List<SocialFriend> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextStart;
  final String? errorMessage;

  ShortMentionsState copyWith({
    String? query,
    List<SocialFriend>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextStart,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShortMentionsState(
      query: query ?? this.query,
      items: items == null
          ? this.items
          : List<SocialFriend>.unmodifiable(items),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextStart: nextStart ?? this.nextStart,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    query,
    items,
    isLoading,
    isLoadingMore,
    hasMore,
    nextStart,
    errorMessage,
  ];
}

class ShortMentionsController extends StateNotifier<ShortMentionsState> {
  ShortMentionsController(this._api) : super(ShortMentionsState.initial());

  final SocialApi _api;
  Timer? _debounce;
  int _requestGeneration = 0;
  bool _disposed = false;

  void search(String query) {
    final clean = query.trim();
    final generation = ++_requestGeneration;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_load(clean, reset: true, generation: generation));
    });
  }

  void clear() {
    if (_disposed) return;
    _requestGeneration += 1;
    _debounce?.cancel();
    state = ShortMentionsState.initial();
  }

  Future<void> retry() {
    return _load(state.query, reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    await _load(state.query, reset: false);
  }

  Future<void> _load(
    String query, {
    required bool reset,
    int? generation,
  }) async {
    if (_disposed) return;
    final currentGeneration = generation ?? ++_requestGeneration;
    if (currentGeneration != _requestGeneration) return;
    final start = reset ? 0 : state.nextStart;
    state = state.copyWith(
      query: query,
      isLoading: reset,
      isLoadingMore: !reset,
      items: reset ? const <SocialFriend>[] : state.items,
      clearError: true,
    );

    final result = await _api.getFriends(
      start: start,
      query: query.isEmpty ? null : query,
    );
    if (_disposed || currentGeneration != _requestGeneration) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (page) {
        final byId = <String, SocialFriend>{
          if (!reset)
            for (final item in state.items) item.targetUser: item,
          for (final item in page.items) item.targetUser: item,
        };
        state = state.copyWith(
          items: byId.values.toList(growable: false),
          isLoading: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextStart: start + page.items.length,
          clearError: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}

class MentionInsertionResult {
  const MentionInsertionResult({
    required this.value,
    required this.token,
    required this.canonicalAccountId,
  });

  final TextEditingValue value;
  final String token;
  final String canonicalAccountId;
}

MentionInsertionResult insertShortMention(
  TextEditingValue current,
  SocialFriend friend,
) {
  final selection = current.selection;
  final cursor = selection.isValid
      ? selection.baseOffset.clamp(0, current.text.length).toInt()
      : current.text.length;
  var fragmentStart = cursor;
  while (fragmentStart > 0) {
    final character = current.text[fragmentStart - 1];
    if (character == '@') {
      fragmentStart -= 1;
      break;
    }
    if (RegExp(r'\s').hasMatch(character)) break;
    fragmentStart -= 1;
  }
  if (fragmentStart >= current.text.length ||
      current.text[fragmentStart] != '@') {
    fragmentStart = cursor;
  }

  final token = mentionTokenForFriend(friend);
  final replacement = '@$token ';
  final replacementEnd =
      cursor < current.text.length &&
          RegExp(r'\s').hasMatch(current.text[cursor])
      ? cursor + 1
      : cursor;
  final text = current.text.replaceRange(
    fragmentStart,
    replacementEnd,
    replacement,
  );
  final nextCursor = fragmentStart + replacement.length;
  return MentionInsertionResult(
    value: current.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: nextCursor),
      composing: TextRange.empty,
    ),
    token: token,
    canonicalAccountId: friend.targetUser,
  );
}

String mentionTokenForFriend(SocialFriend friend) {
  final name = friend.fullName.trim().toLowerCase();
  final slug = name
      .replaceAll(RegExp('[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'^\.+|\.+$'), '');
  if (slug.length >= 2) return slug;

  final fallback = friend.user.trim().toLowerCase();
  final localPart = fallback.contains('@')
      ? fallback.split('@').first
      : fallback;
  final cleaned = localPart.replaceAll(RegExp('[^a-z0-9._+-]'), '');
  return cleaned.length >= 2 ? cleaned : 'aos.user';
}
