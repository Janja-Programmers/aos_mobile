import 'package:flutter/foundation.dart';

import '/core/errors/failures.dart';

import './domain/item_price.dart';
import './domain/usecase.dart';

class ItemPriceProvider with ChangeNotifier {
  final GetAllItemPrices _getAll;
  final CreateItemPrice _create;

  ItemPriceProvider({
    required GetAllItemPrices getAll,
    required CreateItemPrice create,
  }) : _getAll = getAll,
       _create = create;

  List<ItemPrice> _items = [];
  List<ItemPrice> get items => _items;

  Failure? _failure;
  Failure? get failure => _failure;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();

    final res = await _getAll();

    // ✅ SANITY CHECK
    res.fold(
      (f) => debugPrint('❌ Failed to fetch item prices: $f'),
      (list) => debugPrint('✅ Successfully fetched ${list.length} item prices'),
    );

    res.fold((f) => _failure = f, (list) => _items = list);

    _loading = false;
    notifyListeners();
  }

  Future<void> add(ItemPrice itemPrice) async {
    _loading = true;
    notifyListeners();

    final res = await _create(itemPrice);
    res.fold((f) => _failure = f, (created) => _items = [..._items, created]);

    _loading = false;
    notifyListeners();
  }
}
