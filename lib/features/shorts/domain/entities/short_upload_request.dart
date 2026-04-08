import 'package:equatable/equatable.dart';

class ShortUploadRequest extends Equatable {
  final String filePath;
  final String filename;
  final String? caption;
  final List<String>? hashtags;

  const ShortUploadRequest({
    required this.filePath,
    required this.filename,
    this.caption,
    this.hashtags,
  }) : assert(filePath != ''),
       assert(filename != '');

  @override
  List<Object?> get props => [filePath, filename, caption, hashtags];
}
