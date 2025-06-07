import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
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
      images: item.images,
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
    return models.map((model) => model).toList(); // already is WebsiteItem
  }

  @override
  Future<List<WebsiteItem>> getWebsiteItemsByUser(int userId) async {
    final allItems = await localDatasource.getAllWebsiteItems();
    final filtered =
        allItems.where((item) => item.createdBy == userId).toList();
    return filtered.map((model) => model).toList();
  }

  @override
  Future<void> publishWebsiteItem(int itemId, int publishStatus) async {
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
      images: item.images,
      video: item.video,
      shortDescription: item.shortDescription,
      fullDescription: item.fullDescription,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
    );

    await localDatasource.addWebsiteItem(updatedItem);
  }

  @override
  Future<Either<Failure, WebsiteItem>> getItemByCode(String itemCode) async {
    try {
      final websiteItem = await localDatasource.getWebsiteItemByCode(itemCode);
      return Right(websiteItem);
    } catch (e) {
      return Left(Failure('Failed to get website item by code: $e'));
    }
  }
}
