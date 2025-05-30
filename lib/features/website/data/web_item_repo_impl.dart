import '../domain/website_item.dart';
import '../domain/website_item_repo.dart';
import 'web_item_local_datasource.dart';
import 'website_item_model.dart';

class WebsiteItemRepositoryImpl implements WebsiteItemRepository {
  final WebsiteItemLocalDatasource localDatasource;

  WebsiteItemRepositoryImpl(this.localDatasource);

  @override
  Future<void> addWebsiteItem(WebsiteItem item) async {
    final model = WebsiteItemModel(
      id: item.id,
      websiteDisplayName: item.websiteDisplayName,
      itemCode: item.itemCode,
      isPublished: item.isPublished,
      images: item.image != null ? [item.image!] : [],
      video: item.video,
      shortDescription: item.shortDescription,
      fullDescription: item.fullDescription,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );
    await localDatasource.addWebsiteItem(model);
  }

  @override
  Future<List<WebsiteItem>> getWebsiteItems() async {
    final models = await localDatasource.getAllWebsiteItems();
    return models
        .map(
          (model) => WebsiteItem(
            id: model.id,
            websiteDisplayName: model.websiteDisplayName,
            itemCode: model.itemCode,
            isPublished: model.isPublished,
            images: model.image != null ? [model.image!] : [],
            video: model.video,
            shortDescription: model.shortDescription,
            fullDescription: model.fullDescription,
            createdBy: model.createdBy,
            createdAt: model.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<WebsiteItem>> getWebsiteItemsByUser(int userId) async {
    // If you want, implement filtering on the datasource side
    final allItems = await localDatasource.getAllWebsiteItems();
    final filtered =
        allItems.where((item) => item.createdBy == userId).toList();
    return filtered
        .map(
          (model) => WebsiteItem(
            id: model.id,
            websiteDisplayName: model.websiteDisplayName,
            itemCode: model.itemCode,
            isPublished: model.isPublished,
            images: model.image != null ? [model.image!] : [],
            video: model.video,
            shortDescription: model.shortDescription,
            fullDescription: model.fullDescription,
            createdBy: model.createdBy,
            createdAt: model.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> publishWebsiteItem(int itemId, int publishStatus) async {
    // Example: update publish status locally, you might want a datasource method for this
    final allItems = await localDatasource.getAllWebsiteItems();
    final item = allItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    final updatedItem = WebsiteItemModel(
      id: item.id,
      websiteDisplayName: item.websiteDisplayName,
      itemCode: item.itemCode,
      isPublished: publishStatus == 1,
      images: item.image != null ? [item.image!] : [],
      video: item.video,
      shortDescription: item.shortDescription,
      fullDescription: item.fullDescription,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );

    await localDatasource.addWebsiteItem(
      updatedItem,
    ); // Replace old item with updated one
  }
}
