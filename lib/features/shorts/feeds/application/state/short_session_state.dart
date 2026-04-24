import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';

enum SessionStatus { inactive, active, transitioning, paused }

class ShortsSessionState extends Equatable {
  final int activeIndex;
  final SessionStatus status;
  final bool isUserInteracting;
  final ScrollDirection scrollDirection;

  const ShortsSessionState({
    required this.activeIndex,
    required this.status,
    required this.isUserInteracting,
    required this.scrollDirection,
  });

  factory ShortsSessionState.initial() {
    return const ShortsSessionState(
      activeIndex: 0,
      status: SessionStatus.inactive,
      isUserInteracting: false,
      scrollDirection: ScrollDirection.idle,
    );
  }

  ShortsSessionState copyWith({
    int? activeIndex,
    SessionStatus? status,
    bool? isUserInteracting,
    ScrollDirection? scrollDirection,
  }) {
    return ShortsSessionState(
      activeIndex: activeIndex ?? this.activeIndex,
      status: status ?? this.status,
      isUserInteracting: isUserInteracting ?? this.isUserInteracting,
      scrollDirection: scrollDirection ?? this.scrollDirection,
    );
  }

  bool get isActive => status == SessionStatus.active;

  bool get isTransitioning => status == SessionStatus.transitioning;

  @override
  List<Object?> get props => [activeIndex, status, isUserInteracting];
}
