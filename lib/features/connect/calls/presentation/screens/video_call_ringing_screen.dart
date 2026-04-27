import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/video_call_screen.dart';

class VideoRingingScreen extends ConsumerStatefulWidget {
  const VideoRingingScreen({super.key});

  @override
  ConsumerState<VideoRingingScreen> createState() => _VideoRingingScreenState();
}

class _VideoRingingScreenState extends ConsumerState<VideoRingingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = ref.read(callManagerProvider);

      if (state.direction == 'outgoing' || state.direction == 'incoming') {
        ref.read(callManagerProvider.notifier).startLocalVideoPreview();
      }
    });
  }

  @override
  void dispose() {
    ref.read(callManagerProvider.notifier).stopLocalVideoPreviewIfNotInCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);

    final isIncoming = state.direction == 'incoming';

    return Stack(
      children: [
        const VideoCallScreen(showActiveControls: false),

        Positioned(
          left: 24,
          right: 24,
          bottom: 40,
          child: SafeArea(
            child: isIncoming
                ? _IncomingVideoActions(
                    onAccept: manager.acceptIncomingCall,
                    onReject: manager.rejectIncomingCall,
                  )
                : _OutgoingVideoActions(onCancel: manager.endCurrentCall),
          ),
        ),
      ],
    );
  }
}

class _IncomingVideoActions extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingVideoActions({required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CallActionButton(
          icon: Icons.call_end,
          label: 'Decline',
          color: colors.primary,
          onTap: onReject,
        ),
        _CallActionButton(
          icon: Icons.videocam,
          label: 'Accept',
          color: colors.success,
          onTap: onAccept,
        ),
      ],
    );
  }
}

class _OutgoingVideoActions extends StatelessWidget {
  final VoidCallback onCancel;

  const _OutgoingVideoActions({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: _CallActionButton(
        icon: Icons.call_end,
        label: 'Cancel',
        color: colors.primary,
        onTap: onCancel,
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: colors.white,
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(18),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.p.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.white,
          ),
        ),
      ],
    );
  }
}
