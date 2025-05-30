import '../entities/stock_entry.dart';
import '../repo/stock_repo.dart';

class CreateStockEntry {
  final StockRepository repository;

  CreateStockEntry(this.repository);

  Future<void> call(StockEntry entry) {
    return repository.createStockEntry(entry);
  }
}
