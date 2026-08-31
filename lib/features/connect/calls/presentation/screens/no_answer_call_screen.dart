import 'dart:math' as math;

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/utils/call_participant_resolver.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoAnswerCallScreen extends ConsumerWidget {
  const NoAnswerCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final currentUserId = ref.watch(currentUserProvider);

    final participant = CallParticipantResolver.otherParticipant(
      state,
      currentUserId: currentUserId,
      fallbackName: 'No answer',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      body: Stack(
        children: [
          const Positioned.fill(child: _NoAnswerBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    participant.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Answer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _NoAnswerAvatar(
                        initials: participant.initials,
                        avatarUrl: participant.avatarUrl,
                      ),
                    ),
                  ),
                  _NoAnswerActions(
                    isCallingAgain: state.isBusy,
                    onCancel: manager.resetToIdle,
                    onCallAgain: state.isBusy
                        ? null
                        : manager.callAgainAfterNoAnswer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoAnswerAvatar extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const _NoAnswerAvatar({required this.initials, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    const size = 174.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipOval(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF26343A), Color(0xFF111B21)],
            ),
          ),
          child: _AvatarContent(initials: initials, avatarUrl: avatarUrl),
        ),
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const _AvatarContent({required this.initials, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        url: url,
        errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _InitialsAvatar(initials: initials);
        },
      );
    }

    return _InitialsAvatar(initials: initials);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 62,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NoAnswerActions extends StatelessWidget {
  final bool isCallingAgain;
  final VoidCallback onCancel;
  final VoidCallback? onCallAgain;

  const _NoAnswerActions({
    required this.isCallingAgain,
    required this.onCancel,
    required this.onCallAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NoAnswerActionButton(
            label: 'Cancel',
            icon: Icons.close_rounded,
            backgroundColor: const Color(0xFF1F2C33),
            foregroundColor: Colors.white,
            onTap: onCancel,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _NoAnswerActionButton(
            label: isCallingAgain ? 'Calling...' : 'Call Again',
            icon: Icons.call_rounded,
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: const Color(0xFF071014),
            onTap: onCallAgain,
          ),
        ),
      ],
    );
  }
}

class _NoAnswerActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _NoAnswerActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null
          ? backgroundColor.withValues(alpha: 0.50)
          : backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoAnswerBackground extends StatelessWidget {
  const _NoAnswerBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111B21), Color(0xFF071014)],
        ),
      ),
      child: CustomPaint(painter: _NoAnswerPatternPainter()),
    );
  }
}

class _NoAnswerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.026)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const gap = 46.0;
    for (var y = -gap; y < size.height + gap; y += gap) {
      for (var x = -gap; x < size.width + gap; x += gap) {
        final wave = math.sin((x + y) / 90) * 3;
        canvas.drawCircle(Offset(x + wave, y), 6, paint);
        canvas.drawLine(
          Offset(x + 15, y + 9),
          Offset(x + 25, y + 19 + wave),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
