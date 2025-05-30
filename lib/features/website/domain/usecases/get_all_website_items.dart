import '../website_item.dart';
import '../website_item_repo.dart';

class GetAllWebsiteItems {
  final WebsiteItemRepository repository;

  GetAllWebsiteItems(this.repository);

  Future<List<WebsiteItem>> call() {
    return repository.getWebsiteItems();
  }
}
