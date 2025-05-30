import '../entities/stock_entry.dart';

abstract class StockRepository {
  Future<void> createStockEntry(StockEntry entry);
  Future<List<StockEntry>> getStockEntriesByUser(int userId);
  Future<StockEntry?> getStockEntryDetail(int entryId);
}
