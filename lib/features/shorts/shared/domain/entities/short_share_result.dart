import 'package:equatable/equatable.dart';

class ShortShareResult extends Equatable {
  final String shortId;
  final String shareUrl;
  final String channel;
  final int? shareCount;

  const ShortShareResult({
    required this.shortId,
    required this.shareUrl,
    required this.channel,
    this.shareCount,
  });

  @override
  List<Object?> get props => [shortId, shareUrl, channel, shareCount];
}
