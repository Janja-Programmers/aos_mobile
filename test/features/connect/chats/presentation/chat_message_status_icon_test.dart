import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_message_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status icon maps sent, delivered and read timestamps', (
    tester,
  ) async {
    Future<Icon> pumpStatus({DateTime? deliveredAt, DateTime? readAt}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppColorTokens.light],
          ),
          home: Scaffold(
            body: ChatMessageStatusIcon(
              deliveredAt: deliveredAt,
              readAt: readAt,
            ),
          ),
        ),
      );
      return tester.widget<Icon>(find.byType(Icon));
    }

    final sent = await pumpStatus();
    expect(sent.icon, Icons.done);

    final delivered = await pumpStatus(deliveredAt: DateTime.utc(2026));
    expect(delivered.icon, Icons.done_all);
    expect(delivered.color, AppColorTokens.light.textMuted);

    final read = await pumpStatus(
      deliveredAt: DateTime.utc(2026),
      readAt: DateTime.utc(2026, 1, 1, 0, 1),
    );
    expect(read.icon, Icons.done_all);
    expect(read.color, AppColorTokens.light.blue);
  });
}
