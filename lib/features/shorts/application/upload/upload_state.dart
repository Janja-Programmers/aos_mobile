import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

enum UploadStage {
  idle,
  initializing,
  uploading,
  confirming,
  processing,
  ready,
  failed,
}

class UploadState extends Equatable {
  final UploadStage stage;
  final ShortId? shortId;
  final double progress;
  final String? errorMessage;
  final Short? short;

  const UploadState({
    required this.stage,
    required this.shortId,
    required this.progress,
    required this.errorMessage,
    required this.short,
  });

  factory UploadState.initial() {
    return const UploadState(
      stage: UploadStage.idle,
      shortId: null,
      progress: 0,
      errorMessage: null,
      short: null,
    );
  }

  bool get isBusy =>
      stage == UploadStage.initializing ||
      stage == UploadStage.uploading ||
      stage == UploadStage.confirming ||
      stage == UploadStage.processing;

  bool get isDone => stage == UploadStage.ready;

  bool get hasError => stage == UploadStage.failed;

  UploadState copyWith({
    UploadStage? stage,
    ShortId? shortId,
    double? progress,
    String? errorMessage,
    Short? short,
    bool clearError = false,
    bool clearShort = false,
  }) {
    return UploadState(
      stage: stage ?? this.stage,
      shortId: shortId ?? this.shortId,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      short: clearShort ? null : (short ?? this.short),
    );
  }

  @override
  List<Object?> get props => [stage, shortId, progress, errorMessage, short];
}
