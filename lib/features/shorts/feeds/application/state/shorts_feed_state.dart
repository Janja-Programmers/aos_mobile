import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:equatable/equatable.dart';

enum ShortsFeedStatus { idle, loading, ready, empty, error }

class ShortsFeedState extends Equatable {
  final ShortsFeedStatus status;

  /// The ordered feed (source of truth for PageView)
  final List<Short> shorts;

  /// Cursor for pagination
  final String? nextCursor;

  /// Current error (if any)
  final String? errorMessage;

  /// Active page index (deterministic playback anchor)
  final int activeIndex;

  const ShortsFeedState({
    required this.status,
    required this.shorts,
    required this.nextCursor,
    required this.errorMessage,
    required this.activeIndex,
  });

  factory ShortsFeedState.initial() {
    return const ShortsFeedState(
      status: ShortsFeedStatus.idle,
      shorts: [],
      nextCursor: null,
      errorMessage: null,
      activeIndex: 0,
    );
  }

  bool get isLoading => status == ShortsFeedStatus.loading;

  bool get isEmpty => shorts.isEmpty;

  bool get hasError => status == ShortsFeedStatus.error;

  ShortsFeedState copyWith({
    ShortsFeedStatus? status,
    List<Short>? shorts,
    String? nextCursor,
    String? errorMessage,
    int? activeIndex,
  }) {
    return ShortsFeedState(
      status: status ?? this.status,
      shorts: shorts ?? this.shorts,
      nextCursor: nextCursor ?? this.nextCursor,
      errorMessage: errorMessage,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }

  @override
  List<Object?> get props => [
    status,
    shorts,
    nextCursor,
    errorMessage,
    activeIndex,
  ];
}
