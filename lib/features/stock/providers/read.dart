import 'package:flutter/foundation.dart';

import '/core/provider/base_prov.dart';

import '/features/stock/domain/usecases.dart';

import '../domain/entity/stock.dart';

class StockEntryDetailProvider with ChangeNotifier, AsyncState<StockEntry> {
  final GetStockEntryById _getById;
  StockEntryDetailProvider({required GetStockEntryById getById})
    : _getById = getById;

  StockEntry? get entry => data;

  Future<void> fetchById(String id) async {
    setLoading();
    final result = await _getById(id);
    result.fold(setFailure, setSuccess);
  }

  void clear() => clearState();
}
