import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class LiveTopBar extends StatefulWidget {
  final int viewerCount;
  final Duration duration;
  final VoidCallback onEnd;
  final bool isHost;

  const LiveTopBar({
    super.key,
    required this.viewerCount,
    required this.duration,
    required this.onEnd,
    required this.isHost,
  });

  @override
  State<LiveTopBar> createState() => _LiveTopBarState();
}

class _LiveTopBarState extends State<LiveTopBar> {
  late Duration _duration;
  Timer? _timer;
  late int _viewerCount;

  @override
  void initState() {
    super.initState();

    _duration = widget.duration;
    _viewerCount = widget.viewerCount;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void didUpdateWidget(covariant LiveTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _duration = widget.duration;
    }

    if (oldWidget.viewerCount != widget.viewerCount) {
      setState(() {
        _viewerCount = widget.viewerCount;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String format(Duration d) {
    return "${d.inMinutes.toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Positioned(
      top: 40,
      left: 12,
      right: 12,
      child: Row(
        children: [
          /// LEFT GROUP
          Row(
            children: [
              /// LIVE BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: colors.white),
                    const SizedBox(width: 4),

                    Text(
                      "LIVE",
                      style: context.p.copyWith(color: colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              /// TIMER (now reactive 🔥)
              _blackBox(context, format(_duration)),

              const SizedBox(width: 6),

              /// VIEWERS (still reactive from state)
              _blackBox(context, "$_viewerCount", icon: Icons.remove_red_eye),
            ],
          ),

          const Spacer(),

          /// END BUTTON
          GestureDetector(
            onTap: widget.onEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.isHost ? "End" : "Leave",
                style: context.p.copyWith(color: colors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blackBox(BuildContext context, String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.white),
          if (icon != null) const SizedBox(width: 4),
          Text(text, style: context.p.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
