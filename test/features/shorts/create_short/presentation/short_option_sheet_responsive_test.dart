import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'privacy options remain reachable on a small RTL large-text view',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: SafeArea(
                  child: ShortOptionSheet(
                    title: 'Privacy settings',
                    subtitle: 'Who can view this post',
                    current: 'everyone',
                    options: <ShortOptionSheetItem>[
                      ShortOptionSheetItem(
                        'everyone',
                        'Everyone',
                        'Anyone can view this post.',
                      ),
                      ShortOptionSheetItem(
                        'followers',
                        'Followers',
                        'People who follow you.',
                      ),
                      ShortOptionSheetItem(
                        'friends',
                        'Friends',
                        'Followers you follow back.',
                      ),
                      ShortOptionSheetItem(
                        'only_me',
                        'Only you',
                        'Visible only to your account.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Privacy settings'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    },
  );
}
