import 'package:video_player/video_player.dart';

class ShortVideoControllerState {
  final int index;
  final VideoPlayerController? controller;
  final bool isInitializing;
  final bool isReady;
  final Object? error;

  const ShortVideoControllerState({
    required this.index,
    this.controller,
    this.isInitializing = false,
    this.isReady = false,
    this.error,
  });
}
