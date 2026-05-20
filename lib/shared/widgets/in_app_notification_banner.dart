import 'dart:async';
import 'package:flutter/material.dart';

class InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  final Duration duration;

  const InAppNotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, _dismissSafely);
  }

  Future<void> _dismissSafely() async {
    if (_dismissed) return;
    _dismissed = true;

    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (!mounted) return;

    try {
      await _controller.reverse();
    } catch (_) {
      // Best effort only. The widget may already be leaving the tree.
    }

    if (!mounted) return;

    widget.onDismiss();
  }

  void _dismissImmediately() {
    if (_dismissed) return;
    _dismissed = true;

    _dismissTimer?.cancel();
    _dismissTimer = null;

    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slide,
          child: Dismissible(
            key: ValueKey('${widget.title}_${widget.body}'),
            direction: DismissDirection.up,
            onDismissed: (_) => _dismissImmediately(),
            child: GestureDetector(
              onTap: () async {
                widget.onTap?.call();
                await _dismissSafely();
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 14,
                        offset: Offset(0, 6),
                        color: Color(0x33000000),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
