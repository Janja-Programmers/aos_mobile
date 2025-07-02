import 'package:flutter/foundation.dart';

import '/core/provider/base_prov.dart';

import '../domain/usecases.dart';

class StockEntryProvider with ChangeNotifier, AsyncState<List<String>> {
  final GetAllStockEntryNames _getAll;

  StockEntryProvider({required GetAllStockEntryNames getAll})
    : _getAll = getAll;

  List<String> get names => data ?? [];

  Future<void> fetchAll() async {
    if (loading) return;

    setLoading();

    final result = await _getAll();

    result.fold(setFailure, setSuccess);
  }

  Future<void> refresh({bool force = false}) async {
    if (names.isEmpty || force) {
      await fetchAll();
    }
  }

  void clear() => clearState();
}
