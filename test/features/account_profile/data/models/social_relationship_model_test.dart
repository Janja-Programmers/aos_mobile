import 'package:africaonlinestores/features/social/data/social_relationship_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/account_profile_fixture.dart';

void main() {
  group('SocialRelationshipModel', () {
    test('parses the backend follow response and counters', () async {
      final SocialRelationshipModel relationship =
          SocialRelationshipModel.fromJson(
            await loadAccountProfileDataFixture('follow_success.json'),
          );

      expect(relationship.status, 'followed');
      expect(relationship.relationshipStatus, 'following');
      expect(relationship.actionLabel, 'Following');
      expect(relationship.targetTotalFollowers, 1000);
      expect(relationship.currentTotalFollowing, 76);
      expect(relationship.canUnfollow, isTrue);
    });

    test('preserves block fields and prevents follow actions', () async {
      final SocialRelationshipModel relationship =
          SocialRelationshipModel.fromJson(
            await loadAccountProfileDataFixture(
              'public_profile_blocked_by_me.json',
            ),
          );

      expect(relationship.isBlockedByMe, isTrue);
      expect(relationship.isBlocked, isTrue);
      expect(relationship.blockStatus, 'blocked_by_me');
      expect(relationship.canFollow, isFalse);
      expect(relationship.canUnfollow, isFalse);
    });

    test('clamps negative response counters', () {
      final SocialRelationshipModel relationship =
          SocialRelationshipModel.fromJson(<String, dynamic>{
            'target_user': 'safe@example.invalid',
            'target_total_followers': -1,
            'current_total_following': '-5',
          });

      expect(relationship.targetTotalFollowers, 0);
      expect(relationship.currentTotalFollowing, 0);
    });
  });
}
