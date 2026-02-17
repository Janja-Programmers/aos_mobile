import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/catalog/providers/categories_controller.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/utils/category_icon_url.dart';

import 'package:africaonlinestores/features/catalog/widgets/parents_rail.dart';
import 'package:africaonlinestores/features/catalog/widgets/right_pane.dart';

import 'package:africaonlinestores/ui/components/app_search_bar.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesControllerProvider);
    final ctrl = ref.read(categoriesControllerProvider.notifier);

    final parents = state.parents;
    final selectedParent = parents.firstWhere(
      (e) => e.id == state.selectedParentId,
      orElse: () => parents.isNotEmpty
          ? parents.first
          : const CategoryNode(id: '', name: ''),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,

        leading: const BackButton(),

        title: SizedBox(
          height: 52,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: AppSearchBar(
                readOnly: true,
                controller: _searchCtrl,
                onTap: () => context.pushNamed(AppRoutes.nSearch),
                onSubmitted: (_) {},
                onMicTap: () => context.pushNamed(AppRoutes.nSearch),
                onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.loading && parents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive rail width (prevents squishing/overflow)
                        final w = constraints.maxWidth;
                        final railWidth = (w * 0.26).clamp(88.0, 110.0);

                        return Row(
                          children: [
                            ParentsRail(
                              width: railWidth,
                              parents: parents,
                              selectedId: state.selectedParentId,
                              onSelect: ctrl.selectParent,
                              buildIconUrl: buildCategoryIconUrl,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  left: 12,
                                ),
                                child: RightPane(
                                  parent: selectedParent,
                                  buildIconUrl: buildCategoryIconUrl,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
