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
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(curved);

    _fade = Tween<double>(begin: 0, end: 1).animate(curved);

    _scale = Tween<double>(begin: 0.98, end: 1).animate(curved);

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
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Dismissible(
                key: ValueKey(
                  '${widget.title}_${widget.body}_${DateTime.now().microsecondsSinceEpoch}',
                ),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => _dismissImmediately(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          widget.onTap?.call();
                          await _dismissSafely();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 24,
                                spreadRadius: -4,
                                offset: const Offset(0, 10),
                                color: Colors.black.withValues(alpha: 0.18),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NotificationText(
                                  title: widget.title,
                                  body: widget.body,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: 'Dismiss',
                                visualDensity: VisualDensity.compact,
                                splashRadius: 20,
                                onPressed: _dismissSafely,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationText extends StatelessWidget {
  final String title;
  final String body;

  const _NotificationText({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cleanTitle = title.trim();
    final cleanBody = body.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cleanTitle.isNotEmpty)
          Text(
            cleanTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.15,
            ),
          ),
        if (cleanTitle.isNotEmpty && cleanBody.isNotEmpty)
          const SizedBox(height: 3),
        if (cleanBody.isNotEmpty)
          Text(
            cleanBody,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              height: 1.25,
            ),
          ),
      ],
    );
  }
}
