import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_details_screen.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hashtag normalization is local and deterministic', () {
    expect(normalizeShortHashtag(' ##Travel '), 'travel');
    expect(normalizeShortHashtag('two words'), isNull);
    expect(normalizeShortHashtag('###'), isNull);
  });

  test('active mention query follows the collapsed caption cursor', () {
    const value = TextEditingValue(
      text: 'Hello @kin',
      selection: TextSelection.collapsed(offset: 10),
    );
    expect(activeMentionQuery(value), 'kin');
  });

  test('mention insertion replaces the active fragment once', () {
    const friend = SocialFriend(
      user: 'kings@example.com',
      fullName: 'Kings Collection',
      targetUser: 'ACC-KINGS',
    );
    const value = TextEditingValue(
      text: 'Hello @kin',
      selection: TextSelection.collapsed(offset: 10),
    );

    final inserted = insertShortMention(value, friend);

    expect(inserted.value.text, 'Hello @kings.collection ');
    expect(inserted.canonicalAccountId, 'ACC-KINGS');
    expect(inserted.value.selection.baseOffset, inserted.value.text.length);
  });
}
