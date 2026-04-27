import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:africaonlinestores/core/device/device_id.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

class VideoCallScreen extends ConsumerWidget {
  final bool showActiveControls;

  const VideoCallScreen({super.key, this.showActiveControls = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final colors = context.appColors;

    final name = _displayName(state);

    final room = state.room;
    final localVideoTrack = _localVideoTrack(room);
    final remoteVideoTrack = _remoteVideoTrack(room);

    final isConnected = state.uiPhase == UiCallPhase.inCall;

    final VideoTrack? mainTrack = isConnected
        ? remoteVideoTrack
        : localVideoTrack;

    final VideoTrack? pipTrack = isConnected ? localVideoTrack : null;

    return Scaffold(
      backgroundColor: colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: mainTrack != null
                  ? VideoTrackRenderer(
                      mainTrack,
                      fit: VideoViewFit.cover,
                      mirrorMode: mainTrack is LocalVideoTrack
                          ? VideoViewMirrorMode.mirror
                          : VideoViewMirrorMode.off,
                    )
                  : _CameraStartingView(
                      name: name,
                      subtitle: isConnected
                          ? 'Waiting for video...'
                          : 'Starting camera...',
                    ),
            ),

            if (pipTrack != null)
              Positioned(
                top: 70,
                right: 5,
                child: _LocalPreview(track: pipTrack),
              ),

            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                onPressed: manager.endCurrentCall,
                icon: const Icon(Icons.keyboard_arrow_down),
                color: colors.black,
                style: IconButton.styleFrom(
                  backgroundColor: colors.black.withOpacity(0.08),
                ),
              ),
            ),

            if (showActiveControls)
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _control(
                        context,
                        icon: state.isMuted ? Icons.mic_off : Icons.mic,
                        onTap: manager.toggleMute,
                      ),
                      _control(
                        context,
                        icon: state.isLocalVideoEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        onTap: manager.toggleVideo,
                      ),
                      _endButton(context, manager.endCurrentCall),
                      _control(
                        context,
                        icon: state.isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_down,
                        onTap: manager.toggleSpeaker,
                      ),
                      _control(
                        context,
                        icon: Icons.cameraswitch,
                        onTap: () async {
                          final track = localVideoTrack;

                          if (track is LocalVideoTrack) {
                            await track.switchCamera(
                              DeviceId().toString(),
                              fastSwitch: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static LocalVideoTrack? _localVideoTrack(Room? room) {
    if (room == null) return null;

    final publications = room.localParticipant?.videoTrackPublications ?? [];

    for (final pub in publications) {
      final track = pub.track;
      if (track is LocalVideoTrack && !track.muted) {
        return track;
      }
    }

    return null;
  }

  static VideoTrack? _remoteVideoTrack(Room? room) {
    if (room == null) return null;

    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.videoTrackPublications) {
        final track = pub.track;
        if (track is RemoteVideoTrack && !track.muted) {
          return track;
        }
      }
    }

    return null;
  }

  static Widget _control(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: colors.primary,
      style: IconButton.styleFrom(
        backgroundColor: colors.primary.withOpacity(0.08),
      ),
    );
  }

  static Widget _endButton(BuildContext context, VoidCallback onTap) {
    final colors = context.appColors;

    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.call_end),
      color: colors.white,
      style: IconButton.styleFrom(
        backgroundColor: colors.primary,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  static String _displayName(CallState state) {
    if (state.direction == 'incoming') {
      return state.caller?.displayName ??
          state.caller?.userId ??
          'Incoming video call';
    }

    return state.receiver?.displayName ??
        state.receiver?.userId ??
        state.activeCall?.receiver?.displayName ??
        state.activeCall?.receiver?.userId ??
        state.activeCall?.caller?.displayName ??
        state.activeCall?.caller?.userId ??
        'Video call';
  }
}

class _LocalPreview extends StatelessWidget {
  final VideoTrack? track;

  const _LocalPreview({required this.track});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 120,
      height: 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary),
      ),
      child: track != null
          ? VideoTrackRenderer(
              track!,
              fit: VideoViewFit.cover,
              mirrorMode: track is LocalVideoTrack
                  ? VideoViewMirrorMode.mirror
                  : VideoViewMirrorMode.off,
            )
          : Center(child: Icon(Icons.videocam_off, color: colors.black)),
    );
  }
}

class _CameraStartingView extends StatelessWidget {
  final String name;
  final String subtitle;

  const _CameraStartingView({required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(name, style: context.pStrong.copyWith(color: colors.white)),

            const SizedBox(height: 8),

            Text(subtitle, style: context.p.copyWith(color: colors.white)),
          ],
        ),
      ),
    );
  }
}
