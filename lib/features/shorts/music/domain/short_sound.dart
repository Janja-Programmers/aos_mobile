import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:equatable/equatable.dart';

class ShortSound extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String sourceType;
  final String? fileUrl;
  final double durationSeconds;
  final int usageCount;
  final String usageCountDisplay;
  final int favoriteCount;
  final String favoriteCountDisplay;
  final String? status;
  final bool isFavorite;
  final bool canFavorite;
  final bool isCommercialSafe;
  final String? owner;
  final String? createdFromShort;
  final int startMs;
  final int durationMs;
  final double volume;
  final bool isOriginalAudio;

  const ShortSound({
    required this.id,
    required this.title,
    required this.artist,
    this.sourceType = 'uploaded',
    this.fileUrl,
    this.durationSeconds = 0,
    this.usageCount = 0,
    this.usageCountDisplay = '0',
    this.favoriteCount = 0,
    this.favoriteCountDisplay = '0',
    this.status,
    this.isFavorite = false,
    this.canFavorite = false,
    this.isCommercialSafe = false,
    this.owner,
    this.createdFromShort,
    this.startMs = 0,
    this.durationMs = 0,
    this.volume = 1,
    this.isOriginalAudio = false,
  });

  static const original = ShortSound(
    id: 'original',
    title: 'Original audio',
    artist: 'Use the video audio',
    sourceType: 'original',
    isOriginalAudio: true,
    isCommercialSafe: true,
  );

  bool get isOriginal => id == original.id || sourceType == 'original';
  bool get isPlayable => !isOriginal && (fileUrl?.trim().isNotEmpty ?? false);

  String get durationLabel {
    final seconds = durationSeconds.round();
    if (seconds <= 0) return '';
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'artist': artist,
    'source_type': sourceType,
    'file_url': fileUrl,
    'duration_seconds': durationSeconds,
    'usage_count': usageCount,
    'usage_count_display': usageCountDisplay,
    'favorite_count': favoriteCount,
    'favorite_count_display': favoriteCountDisplay,
    'status': status,
    'is_favorite': isFavorite,
    'can_favorite': canFavorite,
    'is_commercial_safe': isCommercialSafe,
    'owner': owner,
    'created_from_short': createdFromShort,
    'start_ms': startMs,
    'duration_ms': durationMs,
    'volume': volume,
    'is_original_audio': isOriginalAudio,
  };

  factory ShortSound.fromJson(Map<String, dynamic> json) {
    final viewerState = json['viewer_state'] is Map<Object?, Object?>
        ? asJsonMap(json['viewer_state'] as Map<Object?, Object?>)
        : const <String, dynamic>{};

    return ShortSound(
      id: json['id']?.toString() ?? json['sound']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? 'uploaded',
      fileUrl: json['file_url']?.toString(),
      durationSeconds: _toDouble(json['duration_seconds']),
      usageCount: _toInt(json['usage_count']),
      usageCountDisplay:
          json['usage_count_display']?.toString() ??
          _toInt(json['usage_count']).toString(),
      favoriteCount: _toInt(json['favorite_count']),
      favoriteCountDisplay:
          json['favorite_count_display']?.toString() ??
          _toInt(json['favorite_count']).toString(),
      status: json['status']?.toString(),
      isFavorite:
          _toBool(viewerState['is_favorited']) ||
          _toBool(json['is_favorite']) ||
          _toBool(json['is_favorited']),
      canFavorite: _toBool(viewerState['can_favorite']),
      isCommercialSafe: _toBool(json['is_commercial_safe']),
      owner: json['owner']?.toString(),
      createdFromShort: json['created_from_short']?.toString(),
      startMs: _toInt(json['start_ms']),
      durationMs: _toInt(json['duration_ms']),
      volume: _toDouble(json['volume'], defaultValue: 1),
      isOriginalAudio: _toBool(json['is_original_audio']),
    );
  }

  ShortSound copyWith({
    String? id,
    String? title,
    String? artist,
    String? sourceType,
    String? fileUrl,
    double? durationSeconds,
    int? usageCount,
    String? usageCountDisplay,
    int? favoriteCount,
    String? favoriteCountDisplay,
    String? status,
    bool? isFavorite,
    bool? canFavorite,
    bool? isCommercialSafe,
    String? owner,
    String? createdFromShort,
    int? startMs,
    int? durationMs,
    double? volume,
    bool? isOriginalAudio,
  }) {
    return ShortSound(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      sourceType: sourceType ?? this.sourceType,
      fileUrl: fileUrl ?? this.fileUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      usageCount: usageCount ?? this.usageCount,
      usageCountDisplay: usageCountDisplay ?? this.usageCountDisplay,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      favoriteCountDisplay: favoriteCountDisplay ?? this.favoriteCountDisplay,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      canFavorite: canFavorite ?? this.canFavorite,
      isCommercialSafe: isCommercialSafe ?? this.isCommercialSafe,
      owner: owner ?? this.owner,
      createdFromShort: createdFromShort ?? this.createdFromShort,
      startMs: startMs ?? this.startMs,
      durationMs: durationMs ?? this.durationMs,
      volume: volume ?? this.volume,
      isOriginalAudio: isOriginalAudio ?? this.isOriginalAudio,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    artist,
    sourceType,
    fileUrl,
    durationSeconds,
    usageCount,
    usageCountDisplay,
    favoriteCount,
    favoriteCountDisplay,
    status,
    isFavorite,
    canFavorite,
    isCommercialSafe,
    owner,
    createdFromShort,
    startMs,
    durationMs,
    volume,
    isOriginalAudio,
  ];

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(Object? value, {double defaultValue = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == 'true' || raw == '1' || raw == 'yes' || raw == 'on';
  }
}
