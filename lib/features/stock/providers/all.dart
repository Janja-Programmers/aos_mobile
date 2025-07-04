import 'package:flutter/foundation.dart';

import '/core/provider/base_prov.dart';

import '../domain/usecases.dart';
import '../domain/entity/stock.dart';

class StockEntryProvider with ChangeNotifier, AsyncState<List<StockEntry>> {
  final GetAllStockEntries _getAll; 

  StockEntryProvider({required GetAllStockEntries getAll}) : _getAll = getAll;

  List<StockEntry> get entries => data ?? [];

  Future<void> fetchAll() async {
    if (loading) return;

    setLoading();

    final result = await _getAll();

    result.fold(setFailure, setSuccess);
  }

  Future<void> refresh({bool force = false}) async {
    if (entries.isEmpty || force) {
      await fetchAll();
    }
  }

  void clear() => clearState();
}
