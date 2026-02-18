import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_state.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>((ref) {
  final api = ref.watch(categoriesApiProvider);
  return CategoriesController(api: api)..loadCategories();
});

class CategoriesController extends StateNotifier<CategoriesState> {
  CategoriesController({required CategoriesApi api})
      : _api = api,
        super(const CategoriesState());

  final CategoriesApi _api;

  Future<Either<Failure, List<CategoryNode>>> loadCategories() async {
    if (state.loading) {
      return Either.right(state.parents);
    }

    state = state.copyWith(loading: true, clearError: true);

    final res = await _api.getCategories();

    if (res.isLeft) {
      final f = res.leftOrNull ?? const Failure('Failed to load categories.');
      state = state.copyWith(loading: false, errorMessage: f.message);
      return Either.left(f);
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;

    if (!ok) {
      final f = Failure((payload['message'] ?? 'Failed to load categories.').toString());
      state = state.copyWith(loading: false, errorMessage: f.message);
      return Either.left(f);
    }

    final dataRaw = payload['data'];
    final parents = <CategoryNode>[];
    if (dataRaw is List) {
      for (final e in dataRaw) {
        if (e is Map) {
          parents.add(CategoryNode.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final selected = parents.isNotEmpty ? parents.first.id : null;

    state = state.copyWith(
      loading: false,
      parents: parents,
      selectedParentId: state.selectedParentId ?? selected,
      clearError: true,
    );

    return Either.right(parents);
  }

  void selectParent(String id) {
    if (id == state.selectedParentId) return;
    state = state.copyWith(selectedParentId: id);
  }

  void clearError() => state = state.copyWith(clearError: true);
}
