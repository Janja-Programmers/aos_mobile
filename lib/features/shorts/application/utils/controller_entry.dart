import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

enum ControllerStatus {
  idle,
  initializing,
  ready,
  playing,
  paused,
  disposed,
  failed,
}

class ControllerEntry extends Equatable {
  final int index;
  final String url;

  final VideoPlayerController controller;

  final ControllerStatus status;

  const ControllerEntry({
    required this.index,
    required this.url,
    required this.controller,
    required this.status,
  });

  ControllerEntry copyWith({ControllerStatus? status}) {
    return ControllerEntry(
      index: index,
      url: url,
      controller: controller,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [index, url, controller, status];
}
