import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/live_fixtures.dart';

void main() {
  test('all backend-supported reaction values are represented', () {
    expect(
      LiveReactionType.values.map((reaction) => reaction.apiValue),
      <String>['like', 'fire', 'clap', 'love', 'wow'],
    );
  });

  test('reaction parser accepts canonical type field', () {
    final reaction = LiveReaction.fromJson(<String, dynamic>{
      'reaction_id': 'REACTION-001',
      'live_id': testLiveId,
      'reaction_type': ' FIRE ',
      'created_at': '2026-08-11T10:01:00Z',
    });

    expect(reaction.id, 'REACTION-001');
    expect(reaction.liveId, testLiveId);
    expect(reaction.type, LiveReactionType.fire);
    expect(reaction.createdAt, DateTime.utc(2026, 8, 11, 10, 1));
  });

  test('unsupported reaction type is rejected', () {
    expect(
      () => LiveReaction.fromJson(<String, dynamic>{
        'reaction_id': 'REACTION-002',
        'live_id': testLiveId,
        'reaction_type': 'laugh',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
