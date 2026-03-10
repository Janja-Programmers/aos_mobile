import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';

import 'package:africaonlinestores/features/ads/ads_create/controllers/create_ad_flow_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/basic/media_section.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/section_tile.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_validator.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';

class BasicStep extends ConsumerStatefulWidget {
  const BasicStep({super.key});

  @override
  ConsumerState<BasicStep> createState() => _BasicStepState();
}

class _BasicStepState extends ConsumerState<BasicStep> {
  final _titleCtrl = TextEditingController();
  bool _initialised = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(adDraftControllerProvider);
    final draft = draftAsync.maybeWhen(data: (v) => v, orElse: () => null);
    if (draft == null) return const SizedBox.shrink();

    if (!_initialised) {
      _initialised = true;
      _titleCtrl.text = draft.title;
    }

    final flowState = ref.watch(createAdFlowControllerProvider);
    final showErrors = flowState.attempted.contains(flowState.index);
    final validation = CreateAdValidator.basic(draft);
    final titleError = showErrors ? validation.fieldErrors['title'] : null;

    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        /// ---------------- TITLE ----------------
        const SectionTitle(title: 'Title *'),
        const SizedBox(height: 10),

        TextField(
          controller: _titleCtrl,
          maxLength: 80,
          onChanged: (v) =>
              ref.read(adDraftControllerProvider.notifier).updateTitle(v),
          decoration: InputDecoration(
            hintText: 'Provide a descriptive title',
            errorText: titleError,
          ).applyDefaults(inputDecorationTheme),
        ),
        const SizedBox(height: 18),

        /// ---------------- LOCATION ----------------
        const SectionTitle(title: 'Location *'),
        const SizedBox(height: 10),

        PickerField(
          value: draft.locationLabel,
          leading: const Icon(Icons.place_outlined),
          placeholder: "Select your location",
          onTap: () async {
            final res = await context.pushNamed<Map<String, dynamic>>(
              AppRoutes.nSelectLocation,
              extra: false,
            );

            if (res == null) return;

            final id = (res['id'] ?? '').toString();
            final label = (res['label'] ?? '').toString();
            if (id.isEmpty) return;

            ref
                .read(adDraftControllerProvider.notifier)
                .setLocation(id: id, label: label);
          },
        ),
        const SizedBox(height: 24),

        /// ---------------- MEDIA SECTION ----------------
        const MediaSection(),
        const SizedBox(height: 24),

        /// ---------------- CATEGORY ----------------
        const SectionTitle(title: 'Category *'),
        const SizedBox(height: 10),

        PickerField(
          value: draft.categoryLabel,
          leading: const Icon(Icons.category_outlined),
          placeholder: "Select a category",
          onTap: () async {
            final categoriesState = ref
                .read(categoriesControllerProvider)
                .value;

            CategoryNode? parentNode;

            if (categoriesState != null && draft.categoryId != null) {
              for (final p in categoriesState.parents) {
                for (final c in p.children) {
                  if (c.id == draft.categoryId) {
                    parentNode = p;
                    break;
                  }
                }
                if (parentNode != null) break;
              }
            }

            final res = await context.pushNamed<Map<String, dynamic>>(
              AppRoutes.nSelectCategory,
              extra: {
                "initialParent": parentNode,
                "openChildren": parentNode != null,
              },
            );

            if (res == null) return;

            final id = (res['id'] ?? '').toString();
            final label = (res['label'] ?? '').toString();

            if (id.isEmpty) return;

            ref
                .read(adDraftControllerProvider.notifier)
                .setCategory(id: id, label: label);
          },
        ),
      ],
    );
  }
}
