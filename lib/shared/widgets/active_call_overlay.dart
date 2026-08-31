import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveCallOverlay extends ConsumerStatefulWidget {
  const ActiveCallOverlay({super.key});

  @override
  ConsumerState<ActiveCallOverlay> createState() => _ActiveCallOverlayState();
}

class _ActiveCallOverlayState extends ConsumerState<ActiveCallOverlay> {
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);

    if (callState.uiPhase != UiCallPhase.inCall &&
        callState.uiPhase != UiCallPhase.joiningRoom) {
      return const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final topPadding = mediaQuery.padding.top;
    final defaultOffset = Offset(size.width - 220, topPadding + 12);
    final currentOffset = _clampOffset(
      _offset ?? defaultOffset,
      screenSize: size,
      topPadding: topPadding,
    );

    return Positioned(
      left: currentOffset.dx,
      top: currentOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset = _clampOffset(
              currentOffset + details.delta,
              screenSize: size,
              topPadding: topPadding,
            );
          });
        },
        child: _ActiveCallPipCard(
          callState: callState,
          onTap: () => CallNavigation.toActiveCall(ref),
          onEnd: () async {
            await manager.endCurrentCall();
          },
        ),
      ),
    );
  }

  Offset _clampOffset(
    Offset value, {
    required Size screenSize,
    required double topPadding,
  }) {
    const width = 208.0;
    const height = 74.0;
    const margin = 10.0;

    final maxX = (screenSize.width - width - margin)
        .clamp(margin, double.infinity)
        .toDouble();
    final maxY = (screenSize.height - height - margin)
        .clamp(topPadding + margin, double.infinity)
        .toDouble();

    return Offset(
      value.dx.clamp(margin, maxX).toDouble(),
      value.dy.clamp(topPadding + margin, maxY).toDouble(),
    );
  }
}

class _ActiveCallPipCard extends StatelessWidget {
  final CallState callState;
  final VoidCallback onTap;
  final Future<void> Function() onEnd;

  const _ActiveCallPipCard({
    required this.callState,
    required this.onTap,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatarUrl = _avatarUrl(callState);
    final name = _displayName(callState);
    final status = callState.uiPhase == UiCallPhase.joiningRoom
        ? 'Connecting'
        : _formatDuration(callState.duration);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 208,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xEE101820),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x22FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _OverlayAvatar(name: name, avatarUrl: avatarUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          callState.callMediaMode == CallMediaMode.video
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          color: colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.white.withValues(alpha: 0.72),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'End call',
                child: InkWell(
                  onTap: () {
                    unawaited(onEnd());
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E4D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _displayName(CallState callState) {
    if (callState.direction == 'incoming') {
      return callState.caller?.displayName ??
          callState.caller?.userId ??
          'Incoming call';
    }

    return callState.receiver?.displayName ??
        callState.receiver?.userId ??
        callState.activeCall?.receiver?.displayName ??
        callState.activeCall?.receiver?.userId ??
        callState.activeCall?.caller?.displayName ??
        callState.activeCall?.caller?.userId ??
        'Calling...';
  }

  static String? _avatarUrl(CallState callState) {
    if (callState.direction == 'incoming') {
      return normalizeMediaUrl(
        callState.caller?.avatarUrl ?? callState.activeCall?.caller?.avatarUrl,
      );
    }

    return normalizeMediaUrl(
      callState.receiver?.avatarUrl ??
          callState.activeCall?.receiver?.avatarUrl ??
          callState.activeCall?.caller?.avatarUrl,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _OverlayAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _OverlayAvatar({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatar = avatarUrl?.trim();
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1) : '?';

    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF263238),
      backgroundImage: avatar != null && avatar.isNotEmpty
          ? AppImageDecode.networkProvider(
              context,
              avatar,
              logicalWidth: 44,
              logicalHeight: 44,
            )
          : null,
      child: avatar == null || avatar.isEmpty
          ? Text(
              initial.toUpperCase(),
              style: TextStyle(
                color: colors.white,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}
