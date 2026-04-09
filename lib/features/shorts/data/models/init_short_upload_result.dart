import 'package:equatable/equatable.dart';

import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class InitShortUploadResult extends Equatable {
  /// Short created in backend
  final ShortId shortId;

  /// Presigned URL (MinIO upload target)
  final String uploadUrl;

  /// File key (optional but useful for debugging / tracking)
  final String? fileKey;

  const InitShortUploadResult({
    required this.shortId,
    required this.uploadUrl,
    this.fileKey,
  });

  @override
  List<Object?> get props => [shortId, uploadUrl, fileKey];
}
