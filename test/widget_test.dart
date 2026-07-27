import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flutter test harness renders a basic AOS shell', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Africa Online Stores'))),
      ),
    );

    expect(find.text('Africa Online Stores'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
