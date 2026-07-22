import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:flutter/material.dart';

class SocialConnectionTile extends StatelessWidget {
  final SocialFriend friend;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final VoidCallback onMoreTap;
  final bool actionLoading;

  const SocialConnectionTile({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onActionTap,
    required this.onMoreTap,
    this.actionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUrl = buildFileUrl(friend.userImage);
    final actionLabel = friend.actionLabel.isNotEmpty
        ? friend.actionLabel
        : _fallbackAction(friend);
    final primaryAction = _isPrimaryAction(actionLabel, friend);
    final actionFg = primaryAction ? colors.white : colors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colors.border,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Text(
                      friend.initials,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          friend.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.p.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (friend.isVerified) ...[
                        const SizedBox(width: 4),
                        const VerifiedBadge(size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _usernameFromEmail(friend.user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pMuted.copyWith(fontSize: 12, height: 1.15),
                  ),
                  if (_showSubtitle(friend)) ...[
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(friend),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.pMuted.copyWith(
                        fontSize: 12,
                        height: 1.15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: actionLoading ? null : onActionTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: 36,
                  constraints: const BoxConstraints(
                    minWidth: 88,
                    maxWidth: 128,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryAction ? colors.primary : colors.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: primaryAction ? colors.primary : colors.border,
                    ),
                    boxShadow: primaryAction
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : const [],
                  ),
                  child: actionLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: actionFg,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _actionIcon(actionLabel, friend),
                              color: actionFg,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                actionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.p.copyWith(
                                  fontSize: 12,
                                  color: actionFg,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onMoreTap,
              icon: Icon(Icons.more_horiz_rounded, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  static String _usernameFromEmail(String value) {
    final clean = value.trim();

    if (clean.contains('@')) {
      return clean.split('@').first;
    }

    return clean;
  }

  static bool _showSubtitle(SocialFriend friend) {
    return friend.relationshipStatus == 'followed_by' ||
        friend.relationshipStatus == 'none';
  }

  static String _subtitle(SocialFriend friend) {
    if (friend.relationshipStatus == 'followed_by') {
      return 'Follows you';
    }

    return 'People you may know';
  }

  static String _fallbackAction(SocialFriend friend) {
    if (friend.isFriend) return 'Friends';
    if (friend.isFollowing) return 'Following';
    if (friend.isFollowedBy) return 'Follow Back';

    return 'Follow';
  }

  static bool _isPrimaryAction(String label, SocialFriend friend) {
    final clean = label.trim().toLowerCase();
    return clean == 'follow' ||
        clean == 'follow back' ||
        (!friend.isFollowing && !friend.isFriend);
  }

  static IconData _actionIcon(String label, SocialFriend friend) {
    final clean = label.trim().toLowerCase();

    if (friend.isFriend || clean == 'friends') {
      return Icons.people_alt_rounded;
    }

    if (friend.isFollowing || clean == 'following') {
      return Icons.check_rounded;
    }

    if (friend.isFollowedBy || clean == 'follow back') {
      return Icons.person_add_alt_1_rounded;
    }

    return Icons.person_add_alt_1_rounded;
  }
}
