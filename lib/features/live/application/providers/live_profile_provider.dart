import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/domain/live_profile_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveProfileSummaryProvider = FutureProvider.autoDispose
    .family<LiveProfileSummary, String>((ref, accountId) async {
      final cleanAccountId = accountId.trim().toUpperCase();
      if (!cleanAccountId.startsWith('ACC-')) {
        throw const Failure('Invalid account reference.');
      }

      final result = await ref
          .read(accountsApiProvider)
          .getProfile(targetUser: cleanAccountId);
      if (result.isLeft) throw result.leftOrNull!;

      final profile = _extractData(result.rightOrNull);
      if (profile.isEmpty) {
        throw const Failure(
          'Invalid profile response.',
          type: FailureType.parse,
        );
      }

      final relationshipBlocked =
          _bool(profile['is_blocked']) ||
          _bool(profile['is_blocked_by_me']) ||
          _bool(profile['has_blocked_me']);
      final account = _first(<Object?>[
        profile['account_id'],
        profile['user'],
        cleanAccountId,
      ]).toUpperCase();
      final rawAvatar = _first(<Object?>[
        profile['avatar'],
        profile['user_image'],
      ]);
      final resolvedAvatar = rawAvatar.isEmpty ? null : buildFileUrl(rawAvatar);

      return LiveProfileSummary(
        accountId: account,
        displayName: _first(<Object?>[
          profile['display_name'],
          profile['full_name'],
          'AOS User',
        ]),
        avatarUrl: resolvedAvatar?.trim().isNotEmpty ?? false
            ? resolvedAvatar
            : null,
        bio: _first(<Object?>[profile['bio']]),
        isVerified: _bool(profile['is_verified']),
        followersCount: _int(
          profile['followers_count'] ?? profile['total_followers'],
        ),
        followingCount: _int(
          profile['following_count'] ?? profile['total_following'],
        ),
        friendsCount: _int(
          profile['friends_count'] ?? profile['total_friends'],
        ),
        isSelf: _bool(profile['is_self']),
        isFollowing: _bool(profile['is_following']),
        isFollowedBy: _bool(profile['is_followed_by']),
        isFriend: _bool(profile['is_friend']),
        isBlocked: relationshipBlocked,
        actionLabel: _first(<Object?>[profile['action_label']]),
      );
    });

Map<String, dynamic> _extractData(Object? payload) {
  final root = asJsonMap(payload);
  final direct = asJsonMap(root['data']);
  if (direct.isNotEmpty) return direct;
  final message = asJsonMap(root['message']);
  final messageData = asJsonMap(message['data']);
  if (messageData.isNotEmpty) return messageData;
  if (message.isNotEmpty) return message;
  return root;
}

String _first(Iterable<Object?> values) {
  for (final value in values) {
    final clean = value?.toString().trim() ?? '';
    if (clean.isNotEmpty && clean.toLowerCase() != 'null') return clean;
  }
  return '';
}

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final clean = value?.toString().trim().toLowerCase() ?? '';
  return clean == '1' || clean == 'true' || clean == 'yes';
}

int _int(Object? value) {
  final parsed = value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? 0;
  return parsed < 0 ? 0 : parsed;
}
