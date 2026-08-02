import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const friend = SocialFriend(
    user: 'jane@example.com',
    fullName: 'Jane Doe',
    targetUser: 'ACCOUNT-0002',
  );

  test('mention insertion replaces the active fragment at the cursor', () {
    const value = TextEditingValue(
      text: 'Hello @ja world',
      selection: TextSelection.collapsed(offset: 9),
    );

    final result = insertShortMention(value, friend);

    expect(result.value.text, 'Hello @jane.doe world');
    expect(result.value.selection.baseOffset, 16);
    expect(result.token, 'jane.doe');
    expect(result.canonicalAccountId, 'ACCOUNT-0002');
  });

  test(
    'mention token falls back to the account login when name is unusable',
    () {
      const unnamed = SocialFriend(
        user: 'kalutu@example.com',
        fullName: '!',
        targetUser: 'ACCOUNT-0003',
      );

      expect(mentionTokenForFriend(unnamed), 'kalutu');
    },
  );
}
