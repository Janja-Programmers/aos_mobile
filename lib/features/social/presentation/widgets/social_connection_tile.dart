import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:flutter/material.dart';

class SocialConnectionTile extends StatelessWidget {
  final SocialFriend friend;
  final VoidCallback onTap;
  final VoidCallback onActionTap;
  final VoidCallback onMoreTap;

  const SocialConnectionTile({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onActionTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUrl = buildFileUrl(friend.userImage);

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
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: colors.blue,
                        ),
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onActionTap,
              child: Container(
                height: 32,
                constraints: const BoxConstraints(minWidth: 76),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  friend.actionLabel.isNotEmpty
                      ? friend.actionLabel
                      : _fallbackAction(friend),
                  style: context.p.copyWith(
                    fontSize: 12,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
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
}
