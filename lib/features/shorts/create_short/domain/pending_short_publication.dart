import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';

class PendingShortPublication {
  const PendingShortPublication({
    required this.sessionId,
    required this.ownerId,
    required this.shortId,
    required this.localMediaPath,
    required this.contentMode,
    required this.caption,
    required this.hashtags,
    required this.audience,
    required this.allowComments,
    required this.allowDownloads,
    required this.sound,
    required this.createdAt,
    this.adId,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String sessionId;
  final String ownerId;
  final String shortId;
  final String localMediaPath;
  final String contentMode;
  final String? adId;
  final String caption;
  final List<String> hashtags;
  final String audience;
  final bool allowComments;
  final bool allowDownloads;
  final ShortSound sound;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schema_version': schemaVersion,
    'session_id': sessionId,
    'owner_id': ownerId,
    'short_id': shortId,
    'local_media_path': localMediaPath,
    'content_mode': contentMode,
    'ad_id': adId,
    'caption': caption,
    'hashtags': hashtags,
    'audience': audience,
    'allow_comments': allowComments,
    'allow_downloads': allowDownloads,
    'sound': sound.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory PendingShortPublication.fromJson(Map<String, dynamic> json) {
    final schemaVersion = _int(json['schema_version'], currentSchemaVersion);
    if (schemaVersion != currentSchemaVersion) {
      throw const FormatException(
        'Unsupported pending Shorts publication schema.',
      );
    }

    final sound = json['sound'];
    final hashtags = json['hashtags'];
    return PendingShortPublication(
      schemaVersion: schemaVersion,
      sessionId: json['session_id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      shortId: json['short_id']?.toString() ?? '',
      localMediaPath: json['local_media_path']?.toString() ?? '',
      contentMode: json['content_mode']?.toString() ?? 'geo',
      adId: _nullable(json['ad_id']),
      caption: json['caption']?.toString() ?? '',
      hashtags: hashtags is List<Object?>
          ? hashtags
                .map((Object? item) => item?.toString() ?? '')
                .where((String item) => item.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
      audience: json['audience']?.toString() ?? 'everyone',
      allowComments: _bool(json['allow_comments'], true),
      allowDownloads: _bool(json['allow_downloads'], false),
      sound: sound is Map<Object?, Object?>
          ? ShortSound.fromJson(Map<String, dynamic>.from(sound))
          : ShortSound.original,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

String? _nullable(Object? value) {
  final clean = value?.toString().trim() ?? '';
  return clean.isEmpty || clean.toLowerCase() == 'null' ? null : clean;
}

int _int(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _bool(Object? value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final clean = value?.toString().trim().toLowerCase() ?? '';
  if (clean == 'true' || clean == '1') return true;
  if (clean == 'false' || clean == '0') return false;
  return fallback;
}
