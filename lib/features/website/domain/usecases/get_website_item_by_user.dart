import '../website_item.dart';
import '../website_item_repo.dart';

class GetWebsiteItemsByUser {
  final WebsiteItemRepository repository;

  GetWebsiteItemsByUser(this.repository);

  Future<List<WebsiteItem>> call(int userId) {
    return repository.getWebsiteItemsByUser(userId);
  }
}
