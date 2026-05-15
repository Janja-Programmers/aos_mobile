import 'package:africaonlinestores/features/shorts/shared/data/models/short_ad_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_ad.dart';

class ShortAdMapper {
  static ShortAd toDomain(ShortAdModel model) {
    return ShortAd(
      id: model.id,
      title: model.title,
      price: model.price,
      currency: model.currency,
      thumbnail: model.thumbnail,
    );
  }
}
