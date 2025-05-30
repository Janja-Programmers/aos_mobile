import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../domain/website_item.dart';
import '../domain/usecases/add_website_item.dart';
import '../domain/usecases/get_all_website_items.dart';
import '../domain/usecases/get_website_item_by_user.dart';

class WebsiteItemProvider extends ChangeNotifier {
  final AddWebsiteItem addWebsiteItem;
  final GetWebsiteItemsByUser getWebsiteItemsByUser;
  final GetAllWebsiteItems getAllWebsiteItems;

  List<WebsiteItem> _websiteItems = [];
  bool _isLoading = false;
  String? _error;

  List<WebsiteItem> get websiteItems => _websiteItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WebsiteItemProvider({
    required this.addWebsiteItem,
    required this.getWebsiteItemsByUser,
    required this.getAllWebsiteItems,
  });

  Future<void> loadWebsiteItemsByUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _websiteItems = await getWebsiteItemsByUser.call(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load website items by user';
      _websiteItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllWebsiteItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _websiteItems = await getAllWebsiteItems.call();
      _error = null;
    } catch (e) {
      _error = 'Failed to load all website items';
      _websiteItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWebsiteItemAndReload(WebsiteItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await addWebsiteItem.call(item);
      _error = null;
      await loadWebsiteItemsByUser(
        item.createdBy,
      ); // reload user's items after add
    } catch (e) {
      _error = 'Failed to create website item';
      _isLoading = false;
      notifyListeners();
    }
  }
}
