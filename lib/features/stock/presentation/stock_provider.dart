import 'package:flutter/material.dart';
import '../domain/entities/stock_entry.dart';
import '../domain/usecases/create_stock_entry.dart';
import '../domain/usecases/get_stock_entry_by_user.dart';
import '../domain/usecases/get_stock_entry_detail.dart';

class StockProvider extends ChangeNotifier {
  final CreateStockEntry createStockEntryUseCase;
  final GetStockEntriesByUser getAllStockEntriesByUserUseCase;
  final GetStockEntryDetail getStockEntryDetailUseCase;

  List<StockEntry> _stockEntries = [];
  bool _isLoading = false;
  String? _error;

  StockEntry? _stockEntryDetail;

  List<StockEntry> get stockEntries => _stockEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StockEntry? get stockEntryDetail => _stockEntryDetail;

  StockProvider({
    required this.createStockEntryUseCase,
    required this.getAllStockEntriesByUserUseCase,
    required this.getStockEntryDetailUseCase,
  });

  Future<void> loadStockEntries(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stockEntries = await getAllStockEntriesByUserUseCase.call(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load stock entries';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStockEntry(StockEntry entry) async {
    _isLoading = true;
    notifyListeners();

    try {
      await createStockEntryUseCase.call(entry);
      _error = null;
      await loadStockEntries(entry.createdBy);
    } catch (e) {
      _error = 'Failed to create stock entry';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStockEntryDetail(int entryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stockEntryDetail = await getStockEntryDetailUseCase.call(entryId);
      _error = null;
    } catch (_) {
      _stockEntryDetail = null;
      _error = 'Failed to load entry detail';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
