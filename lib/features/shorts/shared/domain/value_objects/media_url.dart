import 'package:equatable/equatable.dart';

class MediaUrl extends Equatable {
  final String value;

  const MediaUrl(this.value);

  bool get isHls => value.endsWith('.m3u8');

  bool get isMp4 => value.endsWith('.mp4');

  @override
  List<Object?> get props => [value];
}
