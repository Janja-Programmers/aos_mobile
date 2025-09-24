import 'package:africaonlinestores/shared/utils/doc_status.dart';
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

  /// Create a new entry (defaults to draft)
  Future<StockEntry?> _create(StockEntry entry, {required bool submit}) async {
    setLoading();
    final draft = entry.copyWith(
      docstatus: submit ? DocStatus.submitted : DocStatus.draft,
    );
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

  /// Update an existing entry
  Future<StockEntry?> _updateEntry(
    StockEntry entry, {
    required bool submit,
  }) async {
    if (entry.id.isEmpty) {
      final failure = handleException("Cannot update without Stock Entry ID.");
      setFailure(failure);
      return null;
    }

    if (entry.docstatus == 1 && !submit) {
      final failure = handleException("Cannot update a submitted Stock Entry.");
      setFailure(failure);
      return null;
    }

    setLoading();
    final updated = entry.copyWith(
      docstatus: submit ? DocStatus.submitted : DocStatus.draft,
    );
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

  /// Save or submit
  Future<StockEntry?> saveOrSubmit(StockEntry entry, {bool submit = false}) {
    return entry.id.isEmpty
        ? _create(entry, submit: submit)
        : _updateEntry(entry, submit: submit);
  }

  /// Clear error state
  void clearError() => clearState();

  /// Reset entire provider state
  void reset() => clearState();

  /// A convenience getter for showing proper error messages
  String? get errorMessage => failure?.message;
}
