import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mention search is session-scoped and kept alive by publish screen', () {
    final providers = File(
      'lib/features/shorts/create_short/application/providers/short_creation_providers.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/features/shorts/create_short/presentation/screens/post_short_details_screen.dart',
    ).readAsStringSync();

    expect(providers, contains('StateNotifierProvider.autoDispose'));
    expect(providers, contains('.family<ShortMentionsController'));
    expect(
      screen,
      contains('shortMentionsControllerProvider(widget.sessionId)'),
    );
  });

  test('hashtags own their text controller for the full sheet lifecycle', () {
    final source = File(
      'lib/features/shorts/create_short/presentation/screens/post_short_details_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('class _HashtagPickerSheet extends StatefulWidget'),
    );
    expect(
      source,
      contains('late final TextEditingController _textController;'),
    );
    expect(source, contains('_textController.dispose();'));
    expect(source, contains('onChanged: _controller.setHashtags'));
    expect(source, isNot(contains('final text = TextEditingController();')));
  });

  test(
    'mentions are caption-only and do not have a separate composer action',
    () {
      final source = File(
        'lib/features/shorts/create_short/presentation/screens/post_short_details_screen.dart',
      ).readAsStringSync();

      expect(source, contains('activeMentionQuery(value)'));
      expect(source, contains('_mentionSuggestions(mentionState)'));
      expect(source, isNot(contains("label: 'Mention'")));
      expect(source, isNot(contains('_showMentionSheet')));
    },
  );

  test('mention suggestions have a local Material surface for ListTile ink', () {
    final source = File(
      'lib/features/shorts/create_short/presentation/screens/post_short_details_screen.dart',
    ).readAsStringSync();

    expect(source, contains('child: Material('));
    expect(source, contains('child: _mentionSuggestionBody(state)'));
  });

  test('publish preview owns compact overlays and side-by-side phone layout', () {
    final source = File(
      'lib/features/shorts/create_short/presentation/screens/post_short_details_screen.dart',
    ).readAsStringSync();

    expect(source, contains('flex: 10'));
    expect(source, contains('flex: 11'));
    expect(source, contains('child: composer'));
    expect(source, contains('_PreviewInfoPill'));
    expect(source, isNot(contains("_InfoBadge(label: 'Duration'")));
  });

  test(
    'per-short analytics consumes the canonical endpoint and current totals',
    () {
      final api = File(
        'lib/features/shorts/analytics/data/shorts_analytics_api.dart',
      ).readAsStringSync();
      final models = File(
        'lib/features/shorts/analytics/data/shorts_analytics_models.dart',
      ).readAsStringSync();

      expect(api, contains('ApiEndpoints.getShortAnalytics'));
      expect(api, contains("'short_id': shortId"));
      expect(models, contains("asJsonMap(json['current_totals'])"));
    },
  );

  test('multipart reconciliation reports server-confirmed bytes to UI', () {
    final source = File(
      'lib/core/media/data/media_upload_api.dart',
    ).readAsStringSync();

    expect(source, contains('status.uploadedBytes.clamp(0, sizeBytes)'));
    expect(
      source,
      contains('onSendProgress?.call(reconciledBytes, sizeBytes)'),
    );
    expect(source, contains('_shouldReconcileMultipartFailure'));
    expect(source, contains('reconciliation < 2'));
  });

  test('owner analytics action has a built-in per-short fallback', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart',
    ).readAsStringSync();

    expect(source, contains('showShortAnalyticsSheet'));
    expect(source, contains("title: 'View analytics'"));
    expect(source, contains('shortId: short.id.value'));
  });

  _shortDetailFinalPolishContracts();
  _shortDetailPermissionAndBrandContracts();
}

// Short detail final polish contracts.
void _shortDetailFinalPolishContracts() {
  test('Short detail uses custom share sheet instead of action-rail SharePlus', () {
    final actions = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart',
    ).readAsStringSync();
    final shareSheet = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_share_sheet.dart',
    ).readAsStringSync();

    expect(actions, contains('showShortShareSheet'));
    expect(shareSheet, contains('Send to chats'));
    expect(shareSheet, contains('shareToChat('));
    expect(
      shareSheet,
      contains('barrierColor: Colors.black.withValues(alpha: .46)'),
    );
    expect(shareSheet, isNot(contains('SharePlus.instance.share')));
  });

  test('Short detail rail exposes save and animated sound actions', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart',
    ).readAsStringSync();

    expect(source, contains('Icons.bookmark_border_rounded'));
    expect(source, contains('metrics.saveCount'));
    expect(source, contains('class _SpinningSoundAction'));
    expect(source, contains('showShortSoundDialog'));
  });

  test('bottom info always exposes sound and verified creator affordance', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_bottom_info.dart',
    ).readAsStringSync();

    expect(source, contains('VerifiedBadge(size: 15)'));
    expect(source, contains('Original sound'));
    expect(source, contains('showShortSoundDialog'));
  });

  test('comment and reply row use the same trash deletion lifecycle', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/comments/comments_list/comment_main_row.dart',
    ).readAsStringSync();

    expect(source, contains('Icons.delete_outline_rounded'));
    expect(source, contains('isDeletePending'));
    expect(
      source,
      isNot(contains("isDeletePending ? 'Deleting...' : 'Delete'")),
    );
  });

  test('Use this sound routes to recorder with a canonical preselected sound', () {
    final soundDialog = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_sound_dialog.dart',
    ).readAsStringSync();
    final recorder = File(
      'lib/features/shorts/create_short/presentation/screens/post_short_media_picker_screen.dart',
    ).readAsStringSync();
    final routes = File(
      'lib/features/shorts/shared/navigation/shorts_routes.dart',
    ).readAsStringSync();

    expect(soundDialog, contains("'Use this sound'"));
    expect(soundDialog, contains("'Shorts using this sound'"));
    expect(soundDialog, contains('soundShortsDomain'));
    expect(soundDialog, contains('extra: selectedSound'));
    expect(recorder, contains('final ShortSound? initialSound'));
    expect(
      recorder,
      contains('_selectedSound = widget.initialSound ?? ShortSound.original'),
    );
    expect(
      routes,
      contains('final initialSound = extra is ShortSound ? extra : null'),
    );
  });

  test('custom share sheet keeps a compact screenshot-style action row', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_share_sheet.dart',
    ).readAsStringSync();

    expect(source, contains("Text('Share to'"));
    expect(source, contains("Text('Send to chats'"));
    expect(source, contains("label: 'WhatsApp'"));
    expect(source, contains("label: 'Facebook'"));
    expect(source, contains("label: 'Copy link'"));
    expect(source, contains('maxHeight: size.height * .84'));
    expect(source, isNot(contains('SharePlus.instance.share')));
  });

  test('sound action honors reduced motion while remaining tappable', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart',
    ).readAsStringSync();

    expect(source, contains('MediaQuery.disableAnimationsOf(context)'));
    expect(source, contains('AlwaysStoppedAnimation<double>(0)'));
    expect(source, contains('showShortSoundDialog'));
  });

  test('share-to-chat consumes the backend canonical endpoint', () {
    final source = File(
      'lib/features/shorts/shared/data/api/shorts_share_api.dart',
    ).readAsStringSync();

    expect(source, contains('ApiEndpoints.shareShortToChat'));
    expect(source, contains("'conversation_id': conversationId"));
    expect(source, contains("'event_id': normalizedEventId"));
  });
}

void _shortDetailPermissionAndBrandContracts() {
  test('external Short share actions use requested brand marks and colors', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_share_sheet.dart',
    ).readAsStringSync();

    expect(source, contains('FontAwesomeIcons.whatsapp'));
    expect(source, contains('Color(0xFF25D366)'));
    expect(source, contains('FontAwesomeIcons.facebookF'));
    expect(source, contains('Color(0xFF1877F2)'));
    expect(source, contains('FontAwesomeIcons.xTwitter'));
    expect(source, contains("label: 'Gmail'"));
    expect(source, contains('class _GmailBrandMark'));
    expect(source, contains('#4285F4'));
    expect(source, contains('#EA4335'));
    expect(source, contains('#FBBC04'));
    expect(source, contains('#34A853'));
  });

  test('owner Manage gates destructive delete with backend viewer state', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart',
    ).readAsStringSync();

    expect(source, contains('if (short.isOwner) ...<Widget>['));
    expect(source, contains('if (short.canDelete)'));
    expect(source, contains("title: 'Delete short'"));
    expect(source, contains('destructive: true'));
    expect(source, contains('ShortDeletionCoordinator'));
    expect(source, contains('shortsManagementApiProvider'));
    expect(source, contains("title: 'View analytics'"));
  });
}
