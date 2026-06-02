import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';

class SocialFriendsStrip extends StatelessWidget {
  final List<SocialFriend> friends;
  final VoidCallback? onSeeAll;
  final ValueChanged<SocialFriend>? onFriendTap;
  final int limit;
  final String title;

  const SocialFriendsStrip({
    super.key,
    required this.friends,
    this.onSeeAll,
    this.onFriendTap,
    this.limit = 10,
    this.title = 'Friends',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visibleFriends = friends.take(limit).toList();

    if (visibleFriends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: context.p.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      'See all',
                      style: context.p.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: visibleFriends.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final friend = visibleFriends[index];

                return _SocialFriendItem(
                  friend: friend,
                  onTap: () => onFriendTap?.call(friend),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialFriendItem extends StatelessWidget {
  final SocialFriend friend;
  final VoidCallback? onTap;

  const _SocialFriendItem({required this.friend, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withOpacity(0.28),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: colors.border,
                    backgroundImage: _resolveImage(friend.userImage),
                    child: !friend.hasImage
                        ? Text(
                            friend.initials,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                ),
                if (friend.isVerified)
                  Positioned(
                    right: -1,
                    bottom: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              friend.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _resolveImage(String? imageUrl) {
    final url = buildFileUrl(imageUrl);

    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }
}
