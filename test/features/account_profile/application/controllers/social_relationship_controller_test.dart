import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/social/application/controllers/social_relationship_controller.dart';
import 'package:africaonlinestores/features/social/data/social_relationship_model.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/scripted_social_repository.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  test(
    'follow success stores the backend relationship and count snapshot',
    () async {
      final SocialRelationship relationship = SocialRelationshipModel.fromJson(
        await loadAccountProfileDataFixture('follow_success.json'),
      );
      final ScriptedSocialRepository repository = ScriptedSocialRepository(
        toggleFollowHandler: (_) async => Either.right(relationship),
      );
      final SocialRelationshipController controller =
          SocialRelationshipController(repository);

      await controller.toggleFollow(targetUser: 'public@example.invalid');

      final SocialRelationship? stored = controller.getRelationship(
        'public@example.invalid',
      );
      expect(repository.toggleFollowCalls, 1);
      expect(stored?.relationshipStatus, 'following');
      expect(stored?.targetTotalFollowers, 1000);
      expect(stored?.currentTotalFollowing, 76);
    },
  );

  test('follow failure restores the previous relationship state', () async {
    const SocialRelationship previous = SocialRelationship(
      targetUser: 'public@example.invalid',
      isSelf: false,
      isFollowing: false,
      isFollowedBy: true,
      isFriend: false,
      relationshipStatus: 'followed_by',
      actionLabel: 'Follow Back',
      targetTotalFollowers: 999,
      currentTotalFollowing: 21,
    );
    final ScriptedSocialRepository repository = ScriptedSocialRepository(
      relationshipStatusHandler: (_) async => Either.right(previous),
      toggleFollowHandler: (_) async =>
          Either.left(const Failure('Follow failed.', error: 'FOLLOW_FAILED')),
    );
    final SocialRelationshipController controller =
        SocialRelationshipController(repository);
    await controller.loadRelationshipStatus(
      targetUser: 'public@example.invalid',
    );

    await controller.toggleFollow(targetUser: 'public@example.invalid');

    final SocialRelationship? restored = controller.getRelationship(
      'public@example.invalid',
    );
    expect(repository.toggleFollowCalls, 1);
    expect(restored?.relationshipStatus, previous.relationshipStatus);
    expect(restored?.actionLabel, previous.actionLabel);
    expect(restored?.targetTotalFollowers, 999);
    expect(restored?.currentTotalFollowing, 21);
  });

  test('empty target performs no relationship request', () async {
    final ScriptedSocialRepository repository = ScriptedSocialRepository();
    final SocialRelationshipController controller =
        SocialRelationshipController(repository);

    await controller.toggleFollow(targetUser: '   ');
    await controller.loadRelationshipStatus(targetUser: '   ');

    expect(repository.toggleFollowCalls, 0);
    expect(repository.relationshipStatusCalls, 0);
  });
}
