import 'website_item.dart';

abstract class WebsiteItemRepository {
  Future<void> addWebsiteItem(WebsiteItem item);
  Future<List<WebsiteItem>> getWebsiteItemsByUser(int userId);
  Future<List<WebsiteItem>> getWebsiteItems();
  Future<void> publishWebsiteItem(int itemId, int publishStatus);
}
