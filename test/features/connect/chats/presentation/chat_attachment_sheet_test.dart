import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_input/chat_attachment_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('attachment sheet exposes only backend-supported send paths', (
    tester,
  ) async {
    await tester.pumpTestApp(
      ChatAttachmentSheet(
        onGallery: () {},
        onCamera: () {},
        onDocument: () {},
        onAudio: () {},
      ),
    );

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Document'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('Location'), findsNothing);
    expect(find.text('Contact'), findsNothing);
    expect(find.text('Video call'), findsNothing);
    expect(find.text('Voice call'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
