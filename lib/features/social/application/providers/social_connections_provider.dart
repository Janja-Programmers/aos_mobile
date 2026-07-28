import 'package:africaonlinestores/features/social/application/controllers/social_connections_controller.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final socialConnectionsControllerProvider =
    StateNotifierProvider.family<
      SocialConnectionsController,
      SocialConnectionsState,
      SocialConnectionsArgs
    >((ref, args) {
      return SocialConnectionsController(
        ref.read(socialRepositoryProvider),
        initialTab: args.initialTab,
      );
    });
