import '../website_item_repo.dart';

class PublishWebsiteItem {
  final WebsiteItemRepository repository;

  PublishWebsiteItem(this.repository);

  Future<void> call(int itemId, int publishStatus) {
    return repository.publishWebsiteItem(itemId, publishStatus);
  }
}
