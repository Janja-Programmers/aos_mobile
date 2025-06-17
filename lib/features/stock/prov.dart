import 'package:flutter/material.dart';

import '/core/errors/failures.dart';
import './domain/stock_entry.dart';
import './domain/usecases.dart';

class StockEntryProvider with ChangeNotifier {
  final GetAllStockEntries _getAll;
  StockEntryProvider({required GetAllStockEntries getAll}) : _getAll = getAll;

  List<StockEntry> _entries = [];
  List<StockEntry> get entries => _entries;

  bool _loading = false;
  bool get loading => _loading;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchAll() async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final res = await _getAll();
    res.fold((f) => _failure = f, (list) => _entries = list);

    _loading = false;
    notifyListeners();
  }
}
