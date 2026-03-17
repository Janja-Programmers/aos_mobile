import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/catalog/shared/utils/category_icon_url.dart';
import 'package:africaonlinestores/features/catalog/presentation/widgets/parent_rail.dart';
import 'package:africaonlinestores/features/catalog/presentation/widgets/right_pane.dart';

import 'package:africaonlinestores/shared/components/app_search_bar.dart';

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
        child: Builder(
          builder: (_) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            final parents = state.parents;

            if (parents.isEmpty) {
              return const Center(child: Text('No categories found'));
            }

            final selectedParent = parents.firstWhere(
              (e) => e.id == state.selectedParentId,
              orElse: () => parents.first,
            );

            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
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
              ],
            );
          },
        ),
      ),
    );
  }
}
