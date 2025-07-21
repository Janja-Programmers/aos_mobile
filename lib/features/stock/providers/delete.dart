import 'package:flutter/material.dart';

import '/core/provider/base_prov.dart';

import '../domain/usecases.dart';

class DeleteStockEntryProvider with ChangeNotifier, AsyncState<void> {
  final DeleteStockEntry _delete;

  DeleteStockEntryProvider({required DeleteStockEntry delete})
    : _delete = delete;

  Future<void> deleteEntry(String id) async {
    setLoading();
    final result = await _delete(id);
    result.fold(setFailure, (_) => setSuccess(null));
  }

  void clearError() => reset();

  void reset() => clearState();
}
