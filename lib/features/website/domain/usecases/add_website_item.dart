import '../website_item.dart';
import '../website_item_repo.dart';

class AddWebsiteItem {
  final WebsiteItemRepository repository;

  AddWebsiteItem(this.repository);

  Future<void> call(WebsiteItem item) {
    return repository.addWebsiteItem(item);
  }
}
