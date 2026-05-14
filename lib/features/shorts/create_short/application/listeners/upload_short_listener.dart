import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';

final uploadRouterListenerProvider = Provider.family<void, String>((
  ref,
  sessionId,
) {
  ref.listen(postShortControllerProvider(sessionId), (prev, next) {
    final router = ref.read(appRouterProvider);

    if (next.status == UploadStatus.processing &&
        prev?.status != UploadStatus.processing) {
      router.pushNamed(AppRoutes.nShortDetail);
    }

    if (next.status == UploadStatus.ready &&
        prev?.status != UploadStatus.ready) {
      ref.read(shortsControllerProvider.notifier).loadInitial();
    }
  });
});
