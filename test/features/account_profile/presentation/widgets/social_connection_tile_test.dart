import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connection_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows display name without exposing the opaque account ID', (
    WidgetTester tester,
  ) async {
    const friend = SocialFriend(
      user: 'ACC-ABCDEFGHIJKLMNOPQRST',
      fullName: 'Bobby',
      targetUser: 'ACC-ABCDEFGHIJKLMNOPQRST',
      relationshipStatus: 'friends',
      actionLabel: 'Friends',
      isFriend: true,
    );

    await tester.pumpTestApp(
      SocialConnectionTile(
        friend: friend,
        onTap: () {},
        onActionTap: () {},
        onMoreTap: () {},
      ),
    );

    expect(find.text('Bobby'), findsOneWidget);
    expect(find.text('ACC-ABCDEFGHIJKLMNOPQRST'), findsNothing);
  });
}
