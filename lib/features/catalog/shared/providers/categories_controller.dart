import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';

import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_state.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';

final categoriesControllerProvider =
    AsyncNotifierProvider<CategoriesController, CategoriesState>(
      CategoriesController.new,
    );

class CategoriesController extends AsyncNotifier<CategoriesState> {
  late final CategoriesApi _api;

  @override
  Future<CategoriesState> build() async {
    _api = ref.read(categoriesApiProvider);
    return _loadCategories();
  }

  Future<CategoriesState> _loadCategories() async {
    final res = await _api.getCategories();

    if (res.isLeft) {
      final f = res.leftOrNull ?? const Failure('Failed to load categories.');
      return CategoriesState(loading: false, errorMessage: f.message);
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;

    if (!ok) {
      return CategoriesState(
        loading: false,
        errorMessage: (payload['message'] ?? 'Failed to load categories.')
            .toString(),
      );
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

    return CategoriesState(
      loading: false,
      parents: parents,
      selectedParentId: selected,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadCategories());
  }

  void selectParent(String id) {
    final current = state.value;
    if (current == null) return;

    if (id == current.selectedParentId) return;

    state = AsyncData(current.copyWith(selectedParentId: id));
  }
}
