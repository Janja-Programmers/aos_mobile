import 'package:flutter/material.dart';

import '/core/errors/exception.dart';
import '/core/provider/base_prov.dart';

import '../domain/entity/stock.dart';
import '../domain/usecases.dart';

class CreateStockEntryProvider with ChangeNotifier, AsyncState<StockEntry> {
  final AddStockEntry _add;
  final UpdateStockEntry _update;
  final GetStockEntryById _getById;

  CreateStockEntryProvider({
    required AddStockEntry add,
    required UpdateStockEntry update,
    required GetStockEntryById getById,
  }) : _add = add,
       _update = update,
       _getById = getById;

  bool get isDraft => data?.docstatus == 0;
  bool get isSubmitted => data?.docstatus == 1;

  /// Fetch and set entry
  Future<StockEntry?> getById(String id) async {
    setLoading();
    final result = await _getById(id);
    return result.fold(
      (failure) {
        setFailure(failure);
        return null;
      },
      (entry) {
        setSuccess(entry);
        return entry;
      },
    );
  }

  /// Create a new draft entry
  Future<StockEntry?> createDraft(StockEntry entry) async {
    setLoading();
    final draft = entry.copyWith(docstatus: 0);
    final result = await _add(draft);
    return result.fold(
      (failure) {
        setFailure(failure);
        return null;
      },
      (savedEntry) {
        setSuccess(savedEntry);
        return savedEntry;
      },
    );
  }

  /// Update an existing draft
  Future<StockEntry?> updateDraft(StockEntry entry) async {
    if (entry.id.isEmpty) {
      final failure = handleException("Cannot update without Stock Entry ID.");
      setFailure(failure);
      return null;
    }

    if (entry.docstatus == 1) {
      final failure = handleException("Cannot update a submitted Stock Entry.");
      setFailure(failure);
      return null;
    }

    setLoading();
    final draft = entry.copyWith(docstatus: 0);
    final result = await _update(draft);
    return result.fold(
      (failure) {
        setFailure(failure);
        return null;
      },
      (savedEntry) {
        setSuccess(savedEntry);
        return savedEntry;
      },
    );
  }

  /// Final submission (only allowed on existing drafts)
  Future<StockEntry?> submitFinal(StockEntry entry) async {
    if (entry.id.isEmpty) {
      final failure = handleException(
        "Missing Stock Entry ID for final submission.",
      );
      setFailure(failure);
      return null;
    }

    final updated = entry.copyWith(docstatus: 1);
    setLoading();
    final result = await _update(updated);
    return result.fold(
      (failure) {
        setFailure(failure);
        return null;
      },
      (savedEntry) {
        setSuccess(savedEntry);
        return savedEntry;
      },
    );
  }

  Future<StockEntry?> saveOrSubmit(StockEntry entry, {bool submit = false}) {
    return submit
        ? submitFinal(entry)
        : (entry.id.isEmpty ? createDraft(entry) : updateDraft(entry));
  }

  void clearError() => clearState();

  void reset() => clearState();
}
