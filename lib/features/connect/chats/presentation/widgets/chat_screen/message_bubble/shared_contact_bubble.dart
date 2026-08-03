import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:flutter/material.dart';

class SharedContactBubble extends StatelessWidget {
  const SharedContactBubble({
    super.key,
    required this.payload,
    required this.isMe,
  });

  final ChatContactPayload payload;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final cardColor = isMe
        ? colors.white.withValues(alpha: 0.15)
        : colors.elevated;
    final foreground = isMe ? colors.white : colors.textPrimary;
    final muted = isMe
        ? colors.white.withValues(alpha: 0.70)
        : colors.textMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMe ? colors.white.withValues(alpha: 0.14) : colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCircularAvatar(
                  name: payload.title,
                  imageUrl: payload.avatar,
                  radius: 25,
                  backgroundColor: colors.primary.withValues(alpha: 0.24),
                  textColor: colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payload.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong.copyWith(
                          color: foreground,
                          fontSize: 15,
                        ),
                      ),
                      if (payload.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          payload.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.small.copyWith(color: muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (payload.hasProfileTarget)
                  IconButton(
                    onPressed: () {
                      SocialNavigation.toProfileScreen(
                        context,
                        user: payload.user!,
                        displayName: payload.title,
                        avatar: payload.avatar,
                      );
                    },
                    icon: Icon(Icons.person_outline_rounded, color: foreground),
                    tooltip: l10n.chat_view_profile,
                  ),
              ],
            ),
            if (payload.hasProfileTarget) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    SocialNavigation.toProfileScreen(
                      context,
                      user: payload.user!,
                      displayName: payload.title,
                      avatar: payload.avatar,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foreground,
                    side: BorderSide(
                      color: isMe
                          ? colors.white.withValues(alpha: 0.24)
                          : colors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: Text(l10n.chat_view_contact),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
