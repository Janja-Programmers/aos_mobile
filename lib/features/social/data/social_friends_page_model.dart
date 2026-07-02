import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/social/data/social_friend_model.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

class SocialFriendsPageModel extends SocialFriendsPage {
  const SocialFriendsPageModel({
    required super.items,
    required super.total,
    required super.limit,
    required super.start,
    required super.hasMore,
  });

  factory SocialFriendsPageModel.fromJson(Map<String, dynamic> json) {
    final items = asJsonMapList(
      json['items'],
    ).map(SocialFriendModel.fromJson).toList();

    return SocialFriendsPageModel(
      items: items,
      total: _int(json['total']),
      limit: _int(json['limit'], fallback: 20),
      start: _int(json['start']),
      hasMore: _bool(json['has_more']),
    );
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? fallback;
  }

  static bool _bool(Object? value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    final clean = value.toString().trim().toLowerCase();

    return clean == 'true' || clean == '1' || clean == 'yes';
  }
}
