import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import 'website_item.dart';

abstract class WebsiteItemRepository {
  Future<void> addWebsiteItem(WebsiteItem item);
  Future<List<WebsiteItem>> getWebsiteItemsByUser(int userId);
  Future<List<WebsiteItem>> getWebsiteItems();
  Future<void> publishWebsiteItem(int itemId, int publishStatus);
  Future<Either<Failure, WebsiteItem>> getItemByCode(String itemCode);
}
