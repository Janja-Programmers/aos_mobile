import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

enum ConnectStateType { loading, empty, error }

class ConnectStateView extends StatelessWidget {
  final ConnectStateType type;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const ConnectStateView({
    super.key,
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  const ConnectStateView.loading({
    super.key,
    this.title = 'Loading',
    this.message = 'Please wait while we fetch your data.',
    this.compact = false,
  }) : type = ConnectStateType.loading,
       icon = Icons.sync_rounded,
       actionLabel = null,
       onAction = null;

  const ConnectStateView.empty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : type = ConnectStateType.empty;

  const ConnectStateView.error({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.actionLabel = 'Retry',
    this.onAction,
    this.compact = false,
  }) : type = ConnectStateType.error;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final accentColor = switch (type) {
      ConnectStateType.error => colors.error,
      ConnectStateType.loading => colors.primary,
      ConnectStateType.empty => colors.textMuted,
    };

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: compact ? 20 : 36,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 18 : 24),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StateIcon(type: type, icon: icon, accentColor: accentColor),
                const SizedBox(height: 18),

                Text(title, textAlign: TextAlign.center, style: context.h5),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.pMuted.copyWith(height: 1.45),
                ),

                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAction,
                      icon: Icon(
                        type == ConnectStateType.error
                            ? Icons.refresh_rounded
                            : Icons.add_rounded,
                        size: 18,
                      ),
                      label: Text(actionLabel!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  final ConnectStateType type;
  final IconData icon;
  final Color accentColor;

  const _StateIcon({
    required this.type,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (type == ConnectStateType.loading) {
      return SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: accentColor),
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 22,
              color: colors.primary,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accentColor, size: 32),
    );
  }
}
