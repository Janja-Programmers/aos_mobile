import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/features/social/domain/social_friend.dart';

@immutable
class SocialFriendsPage {
  final List<SocialFriend> items;
  final int total;
  final int limit;
  final int start;
  final bool hasMore;

  const SocialFriendsPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.start,
    required this.hasMore,
  });

  const SocialFriendsPage.empty()
    : items = const [],
      total = 0,
      limit = 20,
      start = 0,
      hasMore = false;

  SocialFriendsPage copyWith({
    List<SocialFriend>? items,
    int? total,
    int? limit,
    int? start,
    bool? hasMore,
  }) {
    return SocialFriendsPage(
      items: items ?? this.items,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      start: start ?? this.start,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
