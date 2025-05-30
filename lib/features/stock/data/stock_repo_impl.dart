import '../domain/entities/stock_entry.dart';
import '../domain/repo/stock_repo.dart';
import 'model/stock_entry_model.dart';
import 'stock_local_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDataSource localDataSource;

  StockRepositoryImpl(this.localDataSource);

  @override
  Future<void> createStockEntry(StockEntry entry) async {
    final model = StockEntryModel(
      id: entry.id,
      date: entry.date,
      company: entry.company,
      stockEntryType: entry.stockEntryType,
      targetWarehouse: entry.targetWarehouse,
      createdBy: entry.createdBy,
      items: entry.items,
    );
    await localDataSource.insertStockEntryWithItems(model);
  }

  @override
  Future<List<StockEntry>> getStockEntriesByUser(int userId) async {
    final models = await localDataSource.getStockEntriesByUser(userId);
    return models;
  }

  @override
  Future<StockEntry?> getStockEntryDetail(int entryId) async {
    return await localDataSource.getStockEntryDetail(entryId);
  }
}
