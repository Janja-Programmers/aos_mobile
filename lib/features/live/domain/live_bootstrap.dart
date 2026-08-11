import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveBootstrap {
  const LiveBootstrap({required this.live, required this.session});

  final LiveStream live;
  final LiveJoinSession session;
}
