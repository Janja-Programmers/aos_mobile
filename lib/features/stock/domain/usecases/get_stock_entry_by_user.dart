import '../entities/stock_entry.dart';
import '../repo/stock_repo.dart';

class GetStockEntriesByUser {
  final StockRepository repository;

  GetStockEntriesByUser(this.repository);

  Future<List<StockEntry>> call(int userId) {
    return repository.getStockEntriesByUser(userId);
  }
}
