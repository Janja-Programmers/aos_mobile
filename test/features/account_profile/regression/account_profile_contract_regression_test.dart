import 'package:africaonlinestores/features/account/domain/account_profile_snapshot.dart';
import 'package:africaonlinestores/features/account/domain/profile_update_request.dart';
import 'package:africaonlinestores/features/social/data/social_relationship_model.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/account_profile_fixture.dart';

void main() {
  test('regression: public serializer does not expose owner email', () async {
    final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
      await loadAccountProfileDataFixture('public_profile_follow.json'),
    );

    expect(profile.email, isNull);
    expect(profile.canEdit, isFalse);
  });

  test(
    'regression: friend state remains Friends instead of Following',
    () async {
      final AccountProfileSnapshot profile = AccountProfileSnapshot.fromJson(
        await loadAccountProfileDataFixture('public_profile_friend.json'),
      );

      expect(profile.relationshipStatus, 'friends');
      expect(profile.actionLabel, 'Friends');
    },
  );

  test('regression: blocked state cannot expose follow capability', () async {
    final SocialRelationshipModel relationship =
        SocialRelationshipModel.fromJson(
          await loadAccountProfileDataFixture(
            'public_profile_blocked_by_me.json',
          ),
        );

    expect(relationship.canInteract, isFalse);
    expect(relationship.canFollow, isFalse);
  });

  test('regression: bio editing follows backend 500-character limit', () {
    expect(ProfileUpdateRequest.bioMaxLength, 500);
  });

  test(
    'regression: profile count rendering uses shared humanizer boundaries',
    () {
      expect(humanizeCount(0), '0');
      expect(humanizeCount(999), '999');
      expect(humanizeCount(1000), '1K');
      expect(humanizeCount(1200), '1.2K');
      expect(humanizeCount(1000000), '1M');
    },
  );
}
