import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

const Object _unsetCategorySelection = Object();

class CategoriesState {
  const CategoriesState({
    this.loading = false,
    this.parents = const <CategoryNode>[],
    this.selectedParentId,
    this.errorMessage,
  });

  final bool loading;
  final List<CategoryNode> parents;
  final String? selectedParentId;
  final String? errorMessage;

  CategoriesState copyWith({
    bool? loading,
    List<CategoryNode>? parents,
    Object? selectedParentId = _unsetCategorySelection,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      loading: loading ?? this.loading,
      parents: parents ?? this.parents,
      selectedParentId: selectedParentId == _unsetCategorySelection
          ? this.selectedParentId
          : selectedParentId as String?,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
