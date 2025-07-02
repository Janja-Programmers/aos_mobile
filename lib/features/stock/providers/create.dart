import 'package:flutter/material.dart';

import '/core/provider/base_prov.dart';

import '../domain/entity/stock.dart';
import '../domain/usecases.dart';

class CreateStockEntryProvider with ChangeNotifier, AsyncState<void> {
  final AddStockEntry _add;

  CreateStockEntryProvider({required AddStockEntry add}) : _add = add;

  Future<void> submit(StockEntry entry) async {
    setLoading();
    final result = await _add(entry);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  void reset() => clearState();
}
