import 'package:africaonlinestores/features/shorts/create_short/domain/pending_short_publication.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_draft.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sound = ShortSound(
    id: 'SOUND-0001',
    title: 'Test sound',
    artist: 'AOS',
    fileUrl: 'https://media.example.com/sound.mp3',
    isCommercialSafe: true,
  );

  test('ShortDraft round-trips typed editor state', () {
    final createdAt = DateTime.utc(2026, 8, 1, 12);
    final draft = ShortDraft(
      schemaVersion: ShortDraft.currentSchemaVersion,
      sessionId: 'session-1',
      ownerId: 'ACCOUNT-0001',
      sourcePath: '/app/shorts/source.mp4',
      trimStartMs: 500,
      trimEndMs: 9500,
      durationMs: 10000,
      videoWidth: 1080,
      videoHeight: 1920,
      selectedSound: sound,
      overlays: const <ShortOverlay>[
        ShortOverlay(
          id: 'caption-1',
          kind: ShortOverlayKind.caption,
          content: 'Caption',
          normalizedPosition: Offset(.5, .84),
        ),
      ],
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final restored = ShortDraft.fromJson(draft.toJson());

    expect(restored, draft);
    expect(restored.toSeed().isDraft, isTrue);
    expect(restored.toSeed().sound.id, sound.id);
  });

  test('ShortDraft rejects an unknown schema', () {
    expect(
      () => ShortDraft.fromJson(<String, dynamic>{'schema_version': 99}),
      throwsFormatException,
    );
  });

  test('PendingShortPublication round-trips canonical publication data', () {
    final job = PendingShortPublication(
      sessionId: 'session-1',
      ownerId: 'ACCOUNT-0001',
      shortId: 'SHORT-2026-00001',
      localMediaPath: '/app/shorts/export.mp4',
      contentMode: 'geo',
      caption: 'Hello @aos.user',
      hashtags: const <String>['hello'],
      audience: 'friends',
      allowComments: true,
      allowDownloads: false,
      sound: sound,
      createdAt: DateTime.utc(2026, 8, 1, 12),
    );

    final restored = PendingShortPublication.fromJson(job.toJson());

    expect(restored.shortId, job.shortId);
    expect(restored.sound.id, sound.id);
    expect(restored.audience, 'friends');
    expect(restored.hashtags, const <String>['hello']);
  });
}
