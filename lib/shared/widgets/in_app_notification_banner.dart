import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
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
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  Timer? _timer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(curve);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);

    _controller.forward();

    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isDismissed) return;
    _isDismissed = true;

    _timer?.cancel();
    _timer = null;

    if (!mounted) return;

    try {
      await _controller.reverse();
    } catch (_) {
      // Best effort only.
    }

    if (!mounted) return;

    widget.onDismiss();
  }

  Future<void> _handleTap() async {
    widget.onTap?.call();
    await _dismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final title = widget.title.trim();
    final body = widget.body.trim();

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.black.withValues(alpha: 0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (title.isNotEmpty)
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),

                                if (title.isNotEmpty && body.isNotEmpty)
                                  const SizedBox(height: 3),

                                if (body.isNotEmpty)
                                  Text(
                                    body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.pMuted.copyWith(
                                      color: colors.textPrimary.withValues(
                                        alpha: 0.68,
                                      ),
                                      height: 1.25,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _dismiss,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: colors.textPrimary.withValues(
                                  alpha: 0.55,
                                ),
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
    );
  }
}
