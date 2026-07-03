import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedLocationBubble extends StatelessWidget {
  const SharedLocationBubble({
    super.key,
    required this.payload,
    required this.isMe,
  });

  final ChatLocationPayload payload;
  final bool isMe;

  Future<void> _openMaps() async {
    final uri = payload.mapsUri;
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isMe ? colors.white : colors.textPrimary;
    final muted = isMe
        ? colors.white.withValues(alpha: 0.70)
        : colors.textMuted;
    final accent = isMe ? colors.white : colors.primary;

    return InkWell(
      onTap: () {
        unawaited(_openMaps());
      },
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isMe
                ? colors.white.withValues(alpha: 0.12)
                : colors.elevated,
            border: Border.all(
              color: isMe
                  ? colors.white.withValues(alpha: 0.14)
                  : colors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 118,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.success.withValues(alpha: 0.24),
                              colors.info.withValues(alpha: 0.20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MapLinePainter(
                          lineColor: colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on_rounded,
                      size: 52,
                      color: colors.primary,
                      shadows: [
                        Shadow(
                          color: colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                color: isMe
                    ? colors.black.withValues(alpha: 0.12)
                    : colors.surfaceBright,
                child: Row(
                  children: [
                    Icon(Icons.map_outlined, color: accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payload.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.pStrong.copyWith(
                              color: foreground,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            payload.mapsUri == null
                                ? payload.subtitle
                                : 'Tap to open in Maps',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.small.copyWith(color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLinePainter extends CustomPainter {
  const _MapLinePainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final first = Path()
      ..moveTo(-12, size.height * 0.72)
      ..lineTo(size.width * 0.35, size.height * 0.42)
      ..lineTo(size.width * 0.62, size.height * 0.48)
      ..lineTo(size.width + 12, size.height * 0.32);

    final second = Path()
      ..moveTo(size.width * 0.18, -8)
      ..lineTo(size.width * 0.32, size.height * 0.44)
      ..lineTo(size.width * 0.28, size.height + 8);

    canvas.drawPath(first, paint);
    canvas.drawPath(second, paint);
  }

  @override
  bool shouldRepaint(covariant _MapLinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
