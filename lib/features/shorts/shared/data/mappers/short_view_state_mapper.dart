import 'package:africaonlinestores/features/shorts/shared/data/models/short_viewer_state_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_viewer_state.dart';

class ShortViewerStateMapper {
  static ShortViewerState toDomain(ShortViewerStateModel model) {
    return ShortViewerState(
      liked: model.liked,
      watched: model.watched,
      watchProgress: model.watchProgress,
      isSaved: model.isSaved,
      isOwner: model.isOwner,
      canEdit: model.canEdit,
      canDelete: model.canDelete,
      canReport: model.canReport,
      targetUser: model.targetUser,
      isSelf: model.isSelf,
      isFollowing: model.isFollowing,
      isFollowedBy: model.isFollowedBy,
      isFriend: model.isFriend,
      relationshipStatus: model.relationshipStatus,
      actionLabel: model.actionLabel,
    );
  }
}
