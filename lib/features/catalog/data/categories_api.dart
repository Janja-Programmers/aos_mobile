import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_repository.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:dio/dio.dart';

class CategoriesApi implements CategoriesRepository {
  CategoriesApi(this._client);
  final ApiClient _client;

  @override
  Future<Either<Failure, List<CategoryNode>>> getCategories() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getCategoriesEndpoint,
      );
      final Either<Failure, Map<String, dynamic>> unwrapped = unwrapFrappe(res);
      return unwrapped.fold(
        (Failure failure) {
          return Either<Failure, List<CategoryNode>>.left(failure);
        },
        (Map<String, dynamic> payload) {
          try {
            return Either<Failure, List<CategoryNode>>.right(
              _parseCategoryTree(payload['data']),
            );
          } on FormatException {
            return Either<Failure, List<CategoryNode>>.left(
              const Failure(
                'Unexpected category response. Please try again.',
                type: FailureType.parse,
              ),
            );
          }
        },
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}

List<CategoryNode> _parseCategoryTree(Object? value) {
  if (value is! List<Object?>) {
    throw const FormatException('Catalog data must be a list.');
  }

  final List<CategoryNode> roots = <CategoryNode>[];
  final Set<String> ids = <String>{};

  for (final Object? item in value) {
    if (item is! Map<Object?, Object?>) {
      throw const FormatException('Category must be an object.');
    }

    final CategoryNode root = CategoryNode.fromJson(asJsonMap(item));
    if (root.parentId != null) {
      throw const FormatException('Root category cannot have a parent.');
    }
    _validateNode(root, ids: ids, expectedParentId: null, depth: 1);
    roots.add(root);
  }

  return List<CategoryNode>.unmodifiable(roots);
}

void _validateNode(
  CategoryNode node, {
  required Set<String> ids,
  required String? expectedParentId,
  required int depth,
}) {
  if (!ids.add(node.id)) {
    throw const FormatException('Category identifiers must be unique.');
  }
  if (node.parentId != expectedParentId) {
    throw const FormatException('Category parent does not match its tree.');
  }
  if (depth > 2 || (depth == 2 && node.children.isNotEmpty)) {
    throw const FormatException('Category tree exceeds two levels.');
  }
  if (node.children.isNotEmpty && !node.isGroup) {
    throw const FormatException('Leaf category cannot contain children.');
  }

  for (final CategoryNode child in node.children) {
    if (child.isGroup) {
      throw const FormatException('Nested category cannot be a group.');
    }
    _validateNode(child, ids: ids, expectedParentId: node.id, depth: depth + 1);
  }
}
