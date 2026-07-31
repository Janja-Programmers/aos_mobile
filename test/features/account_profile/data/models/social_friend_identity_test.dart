import 'package:africaonlinestores/features/social/data/social_friend_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps public account identity and display fields independently', () {
    final friend = SocialFriendModel.fromJson(const <String, dynamic>{
      'account_id': 'ACC-ABCDEFGHIJKLMNOPQRST',
      'user': 'legacy@example.invalid',
      'display_name': 'Bobby',
      'full_name': 'Stale Name',
      'avatar': '/files/bobby.jpg',
      'target_user': 'ACC-ABCDEFGHIJKLMNOPQRST',
    });

    expect(friend.user, 'ACC-ABCDEFGHIJKLMNOPQRST');
    expect(friend.targetUser, 'ACC-ABCDEFGHIJKLMNOPQRST');
    expect(friend.displayName, 'Bobby');
    expect(friend.userImage, '/files/bobby.jpg');
  });

  test('never exposes an opaque account ID as the display name', () {
    final friend = SocialFriendModel.fromJson(const <String, dynamic>{
      'account_id': 'ACC-ABCDEFGHIJKLMNOPQRST',
    });

    expect(friend.displayName, 'AOS User');
  });
}
