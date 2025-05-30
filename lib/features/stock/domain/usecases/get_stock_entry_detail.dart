import '../entities/stock_entry.dart';
import '../repo/stock_repo.dart';

class GetStockEntryDetail {
  final StockRepository repository;

  GetStockEntryDetail(this.repository);

  Future<StockEntry?> call(int entryId) {
    return repository.getStockEntryDetail(entryId);
  }
}
