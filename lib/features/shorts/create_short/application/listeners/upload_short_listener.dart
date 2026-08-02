import 'dart:async';

import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadRouterListenerProvider = Provider.family<void, String>((
  ref,
  sessionId,
) {
  ref.listen(postShortControllerProvider(sessionId), (prev, next) {
    if (next.status == UploadStatus.ready &&
        prev?.status != UploadStatus.ready) {
      unawaited(ref.read(shortsControllerProvider.notifier).loadInitial());
    }
  });
});
