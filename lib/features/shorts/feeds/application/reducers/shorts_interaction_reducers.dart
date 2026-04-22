import 'package:africaonlinestores/features/shorts/feeds/application/state/short_interaction_state.dart';

class ShortInteractionReducer {
  const ShortInteractionReducer();

  ShortInteractionState like(ShortInteractionState state, String shortId) {
    final updated = {...state.likedShortIds, shortId};

    return state.copyWith(likedShortIds: updated);
  }

  ShortInteractionState unlike(ShortInteractionState state, String shortId) {
    final updated = {...state.likedShortIds}..remove(shortId);

    return state.copyWith(likedShortIds: updated);
  }

  ShortInteractionState setLikePending(
    ShortInteractionState state,
    String shortId,
  ) {
    final updated = {...state.pendingLikeActions, shortId};

    return state.copyWith(pendingLikeActions: updated);
  }

  ShortInteractionState clearLikePending(
    ShortInteractionState state,
    String shortId,
  ) {
    final updated = {...state.pendingLikeActions}..remove(shortId);

    return state.copyWith(pendingLikeActions: updated);
  }

  ShortInteractionState toggleMute(ShortInteractionState state) {
    return state.copyWith(isMuted: !state.isMuted);
  }
}
