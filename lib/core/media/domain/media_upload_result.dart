import 'package:africaonlinestores/core/utils/json_utils.dart';

class MediaObject {
  const MediaObject({
    required this.id,
    required this.purpose,
    required this.status,
    required this.visibility,
    required this.originalFilename,
    required this.contentType,
    required this.sizeBytes,
    this.url,
    this.width,
    this.height,
    this.durationSeconds,
  });

  final String id;
  final String purpose;
  final String status;
  final String visibility;
  final String originalFilename;
  final String contentType;
  final int sizeBytes;
  final String? url;
  final int? width;
  final int? height;
  final double? durationSeconds;

  factory MediaObject.fromJson(Map<String, dynamic> json) {
    return MediaObject(
      id: asString(json['id'] ?? json['name'] ?? json['media_id']),
      purpose: asString(json['purpose']),
      status: asString(json['status']),
      visibility: asString(json['visibility']),
      originalFilename: asString(json['original_filename']),
      contentType: asString(json['content_type']),
      sizeBytes: asInt(json['size_bytes']),
      url: asNullableString(json['url']),
      width: asNullableInt(json['width']),
      height: asNullableInt(json['height']),
      durationSeconds: asNullableDouble(json['duration_seconds']),
    );
  }
}

class MediaUploadInitResponse {
  const MediaUploadInitResponse({
    required this.media,
    required this.mediaId,
    required this.uploadUrl,
    required this.uploadHeaders,
    required this.expiresIn,
  });

  final MediaObject media;
  final String mediaId;
  final String uploadUrl;
  final Map<String, String> uploadHeaders;
  final int expiresIn;

  factory MediaUploadInitResponse.fromJson(Map<String, dynamic> json) {
    final media = MediaObject.fromJson(asJsonMap(json['media']));
    final mediaId = asString(json['media_id'] ?? media.id);

    return MediaUploadInitResponse(
      media: media,
      mediaId: mediaId,
      uploadUrl: asString(json['upload_url']),
      uploadHeaders: _stringMap(json['upload_headers']),
      expiresIn: asInt(json['expires_in']),
    );
  }
}

class MediaUploadResult {
  const MediaUploadResult({
    required this.mediaId,
    required this.url,
    required this.media,
  });

  final String mediaId;
  final String url;
  final MediaObject media;

  String get id => mediaId;

  factory MediaUploadResult.fromJson(Map<String, dynamic> json) {
    final media = MediaObject.fromJson(asJsonMap(json['media']));
    final mediaId = asString(json['media_id'] ?? media.id);
    final url = asString(json['url'] ?? media.url);

    return MediaUploadResult(mediaId: mediaId, url: url, media: media);
  }
}

Map<String, String> _stringMap(Object? value) {
  final map = asJsonMap(value);
  final result = <String, String>{};

  for (final entry in map.entries) {
    final key = entry.key.trim();
    final headerValue = entry.value?.toString().trim() ?? '';
    if (key.isNotEmpty && headerValue.isNotEmpty) {
      result[key] = headerValue;
    }
  }

  return result;
}
