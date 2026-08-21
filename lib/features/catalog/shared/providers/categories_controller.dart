import 'dart:async';

import 'package:africaonlinestores/features/catalog/domain/categories_repository.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_state.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>(
      CategoriesController.new,
    );

class CategoriesController extends StateNotifier<CategoriesState> {
  CategoriesController(Ref ref)
    : _repository = ref.read(categoriesRepositoryProvider),
      super(const CategoriesState(loading: true)) {
    unawaited(_loadCategories());
  }

  final CategoriesRepository _repository;
  int _requestGeneration = 0;

  Future<void> _loadCategories() async {
    final int generation = ++_requestGeneration;
    state = state.copyWith(loading: true, clearError: true);

    final res = await _repository.getCategories();

    if (!mounted || generation != _requestGeneration) {
      return;
    }

    if (res.isLeft) {
      state = state.copyWith(
        loading: false,
        errorMessage: res.leftOrNull?.message ?? 'Failed to load categories.',
      );
      return;
    }

    final List<CategoryNode> parents = res.rightOrNull ?? <CategoryNode>[];
    final String? currentSelection = state.selectedParentId;
    final bool selectionStillExists =
        currentSelection != null &&
        parents.any((CategoryNode item) => item.id == currentSelection);
    final String? selected = selectionStillExists
        ? currentSelection
        : (parents.isEmpty ? null : parents.first.id);

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
