import 'package:flutter/material.dart';

import '/core/errors/exception.dart';
import '/core/provider/base_prov.dart';

import '../domain/entity/stock.dart';
import '../domain/usecases.dart';

class CreateStockEntryProvider with ChangeNotifier, AsyncState<void> {
  final AddStockEntry _add;
  final UpdateStockEntry _update;
  StockEntry? currentEntry;

  CreateStockEntryProvider({
    required AddStockEntry add,
    required UpdateStockEntry update,
  }) : _add = add,
       _update = update;

  Future<void> submit(StockEntry entry) async {
    setLoading();
    final result = await _add(entry);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  Future<void> update(StockEntry entry) async {
    setLoading();
    final result = await _update(entry);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  Future<void> submitFinal(StockEntry entry) async {
    if (entry.id.isEmpty) {
      setFailure(
        handleException("Missing Stock Entry ID for final submission."),
      );
      return;
    }

    final updated = entry.copyWith(docstatus: 1);
    setLoading();
    final result = await _update(updated);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  void loadEntry(StockEntry entry) {
    currentEntry = entry;
    notifyListeners();
  }

  void clearError() {
    reset();
  }

  void reset() => clearState();
}
