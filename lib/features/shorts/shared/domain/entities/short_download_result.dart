import 'package:equatable/equatable.dart';

class ShortDownloadResult extends Equatable {
  final String shortId;
  final String downloadUrl;
  final int expiresInSeconds;
  final int? downloadCount;

  const ShortDownloadResult({
    required this.shortId,
    required this.downloadUrl,
    required this.expiresInSeconds,
    this.downloadCount,
  });

  @override
  List<Object?> get props => [
    shortId,
    downloadUrl,
    expiresInSeconds,
    downloadCount,
  ];
}
