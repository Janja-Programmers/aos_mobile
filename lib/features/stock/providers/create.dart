import 'package:flutter/material.dart';

import '/core/errors/exception.dart';
import '/core/provider/base_prov.dart';

import '../domain/entity/stock.dart';
import '../domain/usecases.dart';

class CreateStockEntryProvider with ChangeNotifier, AsyncState<void> {
  final AddStockEntry _add;
  final UpdateStockEntry _update;
  StockEntry? currentEntry;

  final GetStockEntryById _getById;

  CreateStockEntryProvider({
    required AddStockEntry add,
    required UpdateStockEntry update,
    required GetStockEntryById getById,
  }) : _add = add,
       _update = update,
       _getById = getById;

  /// Fetch an existing stock entry by ID
  Future<StockEntry?> getById(String id) async {
    final result = await _getById(id);
    return result.fold((_) => null, (entry) => entry);
  }

  /// Create a new draft entry
  Future<void> createDraft(StockEntry entry) async {
    setLoading();
    final result = await _add(entry);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  /// Update an existing draft
  Future<void> updateDraft(StockEntry entry) async {
    setLoading();
    final result = await _update(entry);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  /// Final submission (only allowed on existing drafts)
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
