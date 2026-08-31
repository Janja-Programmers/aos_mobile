import 'package:africaonlinestores/features/reviews/domain/review_model.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('report flag invokes the supplied review report action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewCard(
            review: AdReview(
              id: 'REV-1',
              rating: 5,
              title: 'Great seller',
              comment: 'Everything was as described.',
              reviewer: 'Reviewer',
              creation: DateTime(2026, 8, 31),
              likeCount: 0,
              dislikeCount: 0,
            ),
            onReport: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Report review'), findsOneWidget);

    await tester.tap(find.byTooltip('Report review'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('report flag is absent when reporting is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewCard(
            review: AdReview(
              id: 'REV-1',
              rating: 4,
              title: 'Good',
              comment: 'Good experience.',
              reviewer: 'Reviewer',
              creation: DateTime(2026, 8, 31),
              likeCount: 0,
              dislikeCount: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Report review'), findsNothing);
  });
}
