import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';

import 'package:africaonlinestores/features/catalog/data/categories_api.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_state.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>(
      (ref) => CategoriesController(ref),
    );

class CategoriesController extends StateNotifier<CategoriesState> {
  CategoriesController(this.ref) : super(const CategoriesState(loading: true)) {
    _api = ref.read(categoriesApiProvider);
    _loadCategories();
  }

  final Ref ref;
  late final CategoriesApi _api;

  Future<void> _loadCategories() async {
    state = state.copyWith(loading: true, clearError: true);

    final res = await _api.getCategories();

    if (res.isLeft) {
      final f = res.leftOrNull ?? const Failure('Failed to load categories.');
      state = state.copyWith(loading: false, errorMessage: f.message);
      return;
    }

    final payload = res.rightOrNull ?? <String, dynamic>{};
    final ok = payload['ok'] == true;

    if (!ok) {
      state = state.copyWith(
        loading: false,
        errorMessage: (payload['message'] ?? 'Failed to load categories.')
            .toString(),
      );
      return;
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
      selectedParentId: selected,
    );
  }

  Future<void> reload() async {
    await _loadCategories();
  }

  void selectParent(String id) {
    if (id == state.selectedParentId) return;

    state = state.copyWith(selectedParentId: id);
  }
}
