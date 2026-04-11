import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'package:africaonlinestores/core/media/livekit_track_events.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';

import 'package:africaonlinestores/features/live/presentation/views/host_live_view.dart';
import 'package:africaonlinestores/features/live/presentation/views/viewer_live_view.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  StreamSubscription<MediaTrackEvent>? _mediaSub;

  lk.LocalVideoTrack? _localVideoTrack;
  lk.RemoteVideoTrack? _remoteVideoTrack;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final liveKit = ref.read(liveKitCoreProvider);
      _mediaSub = liveKit.events.listen(_onMediaEvent);
    });
  }

  void _onMediaEvent(MediaTrackEvent event) {
    if (!mounted) return;

    if (event is LocalVideoTrackEvent) {
      setState(() => _localVideoTrack = event.track);
      return;
    }

    if (event is LocalVideoRemovedEvent) {
      setState(() => _localVideoTrack = null);
      return;
    }

    if (event is RemoteVideoTrackEvent) {
      setState(() => _remoteVideoTrack = event.track);
      return;
    }

    if (event is RemoteVideoRemovedEvent || event is TrackClearedEvent) {
      setState(() {
        _localVideoTrack = null;
        _remoteVideoTrack = null;
      });
      return;
    }
  }

  @override
  void dispose() {
    _mediaSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveManagerProvider);
    final manager = ref.read(liveManagerProvider.notifier);

    // ================= LOADING =================
    if (state.status == LiveStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ================= ERROR =================
    if (state.status == LiveStatus.error) {
      return Scaffold(
        body: Center(child: Text(state.errorMessage ?? 'Something went wrong')),
      );
    }

    // ================= ENDED =================
    if (state.status == LiveStatus.ended) {
      return const Scaffold(body: Center(child: Text('Live ended')));
    }

    // ================= NO SESSION SAFETY =================
    if (state.session == null) {
      return const Scaffold(body: Center(child: Text('No active live')));
    }

    // ================= LIVE =================
    if (state.isHost) {
      return HostLiveView(
        live: state.live,
        viewerCount: state.viewerCount,
        localVideoTrack: _localVideoTrack,
        onEndLive: manager.endLive,
      );
    }

    return ViewerLiveView(
      live: state.live,
      viewerCount: state.viewerCount,
      remoteVideoTrack: _remoteVideoTrack,
      onLeaveLive: manager.leaveLive,
    );
  }
}
