import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:equatable/equatable.dart';

class ShortDraft extends Equatable {
  const ShortDraft({
    required this.schemaVersion,
    required this.sessionId,
    required this.ownerId,
    required this.sourcePath,
    required this.trimStartMs,
    required this.trimEndMs,
    required this.durationMs,
    required this.videoWidth,
    required this.videoHeight,
    required this.selectedSound,
    required this.overlays,
    required this.createdAt,
    required this.updatedAt,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String sessionId;
  final String ownerId;
  final String sourcePath;
  final int trimStartMs;
  final int trimEndMs;
  final int durationMs;
  final double videoWidth;
  final double videoHeight;
  final ShortSound selectedSound;
  final List<ShortOverlay> overlays;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schema_version': schemaVersion,
    'session_id': sessionId,
    'owner_id': ownerId,
    'source_path': sourcePath,
    'trim_start_ms': trimStartMs,
    'trim_end_ms': trimEndMs,
    'duration_ms': durationMs,
    'video_width': videoWidth,
    'video_height': videoHeight,
    'selected_sound': selectedSound.toJson(),
    'overlays': overlays.map((ShortOverlay item) => item.toJson()).toList(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory ShortDraft.fromJson(Map<String, dynamic> json) {
    final version = _asInt(json['schema_version'], 0);
    if (version != currentSchemaVersion) {
      throw const FormatException('Unsupported Shorts draft schema.');
    }

    final rawSound = json['selected_sound'];
    final rawOverlays = json['overlays'];
    return ShortDraft(
      schemaVersion: version,
      sessionId: json['session_id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      sourcePath: json['source_path']?.toString() ?? '',
      trimStartMs: _asInt(json['trim_start_ms'], 0),
      trimEndMs: _asInt(json['trim_end_ms'], 0),
      durationMs: _asInt(json['duration_ms'], 0),
      videoWidth: _asDouble(json['video_width'], 0),
      videoHeight: _asDouble(json['video_height'], 0),
      selectedSound: rawSound is Map<Object?, Object?>
          ? ShortSound.fromJson(Map<String, dynamic>.from(rawSound))
          : ShortSound.original,
      overlays: rawOverlays is List
          ? rawOverlays
                .whereType<Map<Object?, Object?>>()
                .map(
                  (Map<Object?, Object?> value) =>
                      ShortOverlay.fromJson(Map<String, dynamic>.from(value)),
                )
                .toList(growable: false)
          : const <ShortOverlay>[],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  ShortEditorSeed toSeed() => ShortEditorSeed(
    sessionId: sessionId,
    sourcePath: sourcePath,
    sound: selectedSound,
    trimStart: Duration(milliseconds: trimStartMs),
    trimEnd: Duration(milliseconds: trimEndMs),
    overlays: overlays,
    ownerId: ownerId,
    isDraft: true,
  );

  @override
  List<Object?> get props => <Object?>[
    schemaVersion,
    sessionId,
    ownerId,
    sourcePath,
    trimStartMs,
    trimEndMs,
    durationMs,
    videoWidth,
    videoHeight,
    selectedSound,
    overlays,
    createdAt,
    updatedAt,
  ];
}

int _asInt(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
