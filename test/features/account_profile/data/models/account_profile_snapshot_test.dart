import 'package:africaonlinestores/features/account/domain/account_profile_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/account_profile_fixture.dart';

void main() {
  group('AccountProfileSnapshot', () {
    test('parses owner-only fields and live state', () async {
      final Map<String, dynamic> data = await loadAccountProfileDataFixture(
        'own_profile.json',
      );

      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        data,
      );

      expect(profile.user, 'owner@example.invalid');
      expect(profile.email, 'owner@example.invalid');
      expect(profile.canEdit, isTrue);
      expect(profile.hasLiveRoom, isTrue);
      expect(profile.liveId, 'LIVE-TEST-001');
      expect(profile.totalFollowersDisplay, '1.2K');
      expect(profile.totalShortLikesDisplay, '2.1M');
    });

    test('public profile does not require owner email', () async {
      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        await loadAccountProfileDataFixture('public_profile_follow.json'),
      );

      expect(profile.email, isNull);
      expect(profile.canEdit, isFalse);
      expect(profile.allowsSocialInteraction, isTrue);
    });

    test('preserves backend friend action exactly', () async {
      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        await loadAccountProfileDataFixture('public_profile_friend.json'),
      );

      expect(profile.relationshipStatus, 'friends');
      expect(profile.actionLabel, 'Friends');
      expect(profile.isFriend, isTrue);
      expect(profile.isFollowing, isTrue);
    });

    test('blocked profile disables social interaction', () async {
      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        await loadAccountProfileDataFixture(
          'public_profile_blocked_by_me.json',
        ),
      );

      expect(profile.isBlockedByMe, isTrue);
      expect(profile.isBlocked, isTrue);
      expect(profile.allowsSocialInteraction, isFalse);
    });

    test('deleted profile remains redacted and unavailable', () async {
      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        await loadAccountProfileDataFixture('public_profile_deleted.json'),
      );

      expect(profile.isDeleted, isTrue);
      expect(profile.email, isNull);
      expect(profile.bio, isEmpty);
      expect(profile.userImage, isNull);
      expect(profile.totalFollowers, 0);
      expect(profile.isVerified, isFalse);
      expect(profile.allowsSocialInteraction, isFalse);
    });

    test('clamps malformed negative count values to zero', () {
      final AccountProfileSnapshot profile =
          AccountProfileSnapshot.fromJson(const <String, dynamic>{
            'user': 'safe@example.invalid',
            'total_followers': -4,
            'total_following': '-2',
            'total_friends': -1.5,
            'total_short_likes': 'invalid',
          });

      expect(profile.totalFollowers, 0);
      expect(profile.totalFollowing, 0);
      expect(profile.totalFriends, 0);
      expect(profile.totalShortLikes, 0);
    });

    test('prefers backend public identity and display fields', () {
      final AccountProfileSnapshot profile =
          AccountProfileSnapshot.fromJson(const <String, dynamic>{
            'account_id': 'ACC-ABCDEFGHIJKLMNOPQRST',
            'user': 'legacy@example.invalid',
            'display_name': 'Bobby',
            'full_name': 'Stale Name',
            'avatar': '/files/bobby.jpg',
          });

      expect(profile.user, 'ACC-ABCDEFGHIJKLMNOPQRST');
      expect(profile.fullName, 'Bobby');
      expect(profile.userImage, '/files/bobby.jpg');
    });
  });
}
