import 'dart:ui';

import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:equatable/equatable.dart';

/// Recording limits represented by the production design.
enum ShortRecordingLimit {
  fifteenSeconds(Duration(seconds: 15), '15s'),
  sixtySeconds(Duration(seconds: 60), '60s'),
  threeMinutes(Duration(minutes: 3), '3m');

  const ShortRecordingLimit(this.duration, this.label);

  final Duration duration;
  final String label;
}

enum ShortRecorderPhase {
  initializing,
  ready,
  starting,
  recording,
  stopping,
  recorded,
  permissionDenied,
  unavailable,
  error,
}

class ShortRecorderState extends Equatable {
  const ShortRecorderState({
    required this.phase,
    required this.limit,
    required this.elapsed,
    this.recordedPath,
    this.errorMessage,
    this.cameraCount = 0,
    this.cameraIndex = 0,
    this.flashEnabled = false,
  });

  factory ShortRecorderState.initial() => const ShortRecorderState(
    phase: ShortRecorderPhase.initializing,
    limit: ShortRecordingLimit.fifteenSeconds,
    elapsed: Duration.zero,
  );

  final ShortRecorderPhase phase;
  final ShortRecordingLimit limit;
  final Duration elapsed;
  final String? recordedPath;
  final String? errorMessage;
  final int cameraCount;
  final int cameraIndex;
  final bool flashEnabled;

  bool get isBusy =>
      phase == ShortRecorderPhase.initializing ||
      phase == ShortRecorderPhase.starting ||
      phase == ShortRecorderPhase.stopping;

  bool get isRecording => phase == ShortRecorderPhase.recording;
  bool get canRecord => phase == ShortRecorderPhase.ready;
  double get progress {
    final max = limit.duration.inMilliseconds;
    if (max <= 0) return 0;
    return (elapsed.inMilliseconds / max).clamp(0, 1).toDouble();
  }

  ShortRecorderState copyWith({
    ShortRecorderPhase? phase,
    ShortRecordingLimit? limit,
    Duration? elapsed,
    String? recordedPath,
    String? errorMessage,
    int? cameraCount,
    int? cameraIndex,
    bool? flashEnabled,
    bool clearRecordedPath = false,
    bool clearError = false,
  }) {
    return ShortRecorderState(
      phase: phase ?? this.phase,
      limit: limit ?? this.limit,
      elapsed: elapsed ?? this.elapsed,
      recordedPath: clearRecordedPath
          ? null
          : recordedPath ?? this.recordedPath,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      cameraCount: cameraCount ?? this.cameraCount,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      flashEnabled: flashEnabled ?? this.flashEnabled,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    phase,
    limit,
    elapsed,
    recordedPath,
    errorMessage,
    cameraCount,
    cameraIndex,
    flashEnabled,
  ];
}

enum ShortOverlayKind { text, sticker, caption }

class ShortOverlay extends Equatable {
  const ShortOverlay({
    required this.id,
    required this.kind,
    required this.content,
    required this.normalizedPosition,
    this.colorValue = 0xFFFFFFFF,
    this.scale = 1,
  });

  final String id;
  final ShortOverlayKind kind;
  final String content;

  /// Center of the overlay relative to the visible video canvas, in [0, 1].
  final Offset normalizedPosition;
  final int colorValue;
  final double scale;

  ShortOverlay copyWith({
    String? content,
    Offset? normalizedPosition,
    int? colorValue,
    double? scale,
  }) {
    return ShortOverlay(
      id: id,
      kind: kind,
      content: content ?? this.content,
      normalizedPosition: normalizedPosition ?? this.normalizedPosition,
      colorValue: colorValue ?? this.colorValue,
      scale: scale ?? this.scale,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'kind': kind.name,
    'content': content,
    'x': normalizedPosition.dx,
    'y': normalizedPosition.dy,
    'color': colorValue,
    'scale': scale,
  };

  factory ShortOverlay.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind']?.toString() ?? '';
    return ShortOverlay(
      id: json['id']?.toString() ?? '',
      kind: ShortOverlayKind.values.firstWhere(
        (ShortOverlayKind value) => value.name == kindName,
        orElse: () => ShortOverlayKind.text,
      ),
      content: json['content']?.toString() ?? '',
      normalizedPosition: Offset(
        _asDouble(json['x'], .5).clamp(0, 1).toDouble(),
        _asDouble(json['y'], .5).clamp(0, 1).toDouble(),
      ),
      colorValue: _asInt(json['color'], 0xFFFFFFFF),
      scale: _asDouble(json['scale'], 1).clamp(.5, 3).toDouble(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    kind,
    content,
    normalizedPosition,
    colorValue,
    scale,
  ];
}

enum ShortExportPhase { idle, exporting, complete, error }

class ShortEditorSeed extends Equatable {
  const ShortEditorSeed({
    required this.sessionId,
    required this.sourcePath,
    this.sound = ShortSound.original,
    this.trimStart = Duration.zero,
    this.trimEnd,
    this.overlays = const <ShortOverlay>[],
    this.ownerId = '',
    this.isDraft = false,
    this.deleteSourceOnDiscard = true,
  });

  final String sessionId;
  final String sourcePath;
  final ShortSound sound;
  final Duration trimStart;
  final Duration? trimEnd;
  final List<ShortOverlay> overlays;
  final String ownerId;
  final bool isDraft;
  final bool deleteSourceOnDiscard;

  @override
  List<Object?> get props => <Object?>[
    sessionId,
    sourcePath,
    sound,
    trimStart,
    trimEnd,
    overlays,
    ownerId,
    isDraft,
    deleteSourceOnDiscard,
  ];
}

class ShortEditorState extends Equatable {
  const ShortEditorState({
    required this.sessionId,
    required this.sourcePath,
    required this.ownerId,
    required this.duration,
    required this.videoSize,
    required this.trimStart,
    required this.trimEnd,
    required this.selectedSound,
    required this.overlays,
    required this.exportPhase,
    required this.exportProgress,
    required this.isInitialized,
    required this.hasUnsavedChanges,
    required this.isDraft,
    required this.deleteSourceOnDiscard,
    this.exportedPath,
    this.errorMessage,
  });

  factory ShortEditorState.initial(ShortEditorSeed seed) => ShortEditorState(
    sessionId: seed.sessionId,
    sourcePath: seed.sourcePath,
    ownerId: seed.ownerId,
    duration: Duration.zero,
    videoSize: Size.zero,
    trimStart: seed.trimStart,
    trimEnd: seed.trimEnd ?? Duration.zero,
    selectedSound: seed.sound,
    overlays: List<ShortOverlay>.unmodifiable(seed.overlays),
    exportPhase: ShortExportPhase.idle,
    exportProgress: 0,
    isInitialized: false,
    hasUnsavedChanges: true,
    isDraft: seed.isDraft,
    deleteSourceOnDiscard: seed.deleteSourceOnDiscard,
  );

  final String sessionId;
  final String sourcePath;
  final String ownerId;
  final Duration duration;
  final Size videoSize;
  final Duration trimStart;
  final Duration trimEnd;
  final ShortSound selectedSound;
  final List<ShortOverlay> overlays;
  final ShortExportPhase exportPhase;
  final double exportProgress;
  final bool isInitialized;
  final bool hasUnsavedChanges;
  final bool isDraft;
  final bool deleteSourceOnDiscard;
  final String? exportedPath;
  final String? errorMessage;

  bool get isExporting => exportPhase == ShortExportPhase.exporting;
  bool get hasVisualEdits =>
      overlays.isNotEmpty ||
      trimStart > Duration.zero ||
      (duration > Duration.zero && trimEnd < duration);
  Duration get selectedDuration => trimEnd - trimStart;

  ShortEditorState copyWith({
    String? sourcePath,
    Duration? duration,
    Size? videoSize,
    Duration? trimStart,
    Duration? trimEnd,
    ShortSound? selectedSound,
    List<ShortOverlay>? overlays,
    ShortExportPhase? exportPhase,
    double? exportProgress,
    bool? isInitialized,
    bool? hasUnsavedChanges,
    bool? isDraft,
    bool? deleteSourceOnDiscard,
    String? exportedPath,
    String? errorMessage,
    bool clearExportedPath = false,
    bool clearError = false,
  }) {
    return ShortEditorState(
      sessionId: sessionId,
      sourcePath: sourcePath ?? this.sourcePath,
      ownerId: ownerId,
      duration: duration ?? this.duration,
      videoSize: videoSize ?? this.videoSize,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      selectedSound: selectedSound ?? this.selectedSound,
      overlays: overlays == null
          ? this.overlays
          : List<ShortOverlay>.unmodifiable(overlays),
      exportPhase: exportPhase ?? this.exportPhase,
      exportProgress: exportProgress ?? this.exportProgress,
      isInitialized: isInitialized ?? this.isInitialized,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isDraft: isDraft ?? this.isDraft,
      deleteSourceOnDiscard:
          deleteSourceOnDiscard ?? this.deleteSourceOnDiscard,
      exportedPath: clearExportedPath
          ? null
          : exportedPath ?? this.exportedPath,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    sessionId,
    sourcePath,
    ownerId,
    duration,
    videoSize,
    trimStart,
    trimEnd,
    selectedSound,
    overlays,
    exportPhase,
    exportProgress,
    isInitialized,
    hasUnsavedChanges,
    isDraft,
    deleteSourceOnDiscard,
    exportedPath,
    errorMessage,
  ];
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
