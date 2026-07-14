import 'package:africaonlinestores/features/shorts/shared/data/models/short_creator_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_creator.dart';

class ShortCreatorMapper {
  static ShortCreator toDomain(ShortCreatorModel model) {
    return ShortCreator(
      user: model.user,
      displayName: model.displayName,
      avatar: model.avatar,
      isVerified: model.isVerified,
      isLive: model.isLive,
      liveId: model.liveId,
      liveStatus: model.liveStatus,
      seller: model.seller == null
          ? null
          : ShortCreatorSeller(id: model.seller!.id),
    );
  }
}
