import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

abstract interface class CategoriesRepository {
  Future<Either<Failure, List<CategoryNode>>> getCategories();
}
