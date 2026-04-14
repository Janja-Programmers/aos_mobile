import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/basic/media_section.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/section_tile.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_validator.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';

import 'package:africaonlinestores/shared/components/picker_field.dart';

class BasicStep extends ConsumerStatefulWidget {
  const BasicStep({super.key});

  @override
  ConsumerState<BasicStep> createState() => _BasicStepState();
}

class _BasicStepState extends ConsumerState<BasicStep> {
  final _titleCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(adDraftControllerProvider.notifier).updateTitle(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(adDraftControllerProvider);

    /// Always keep latest draft even during AsyncLoading
    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;

    /// Sync controller with draft safely
    if (_titleCtrl.text != draft.title) {
      _titleCtrl.value = TextEditingValue(
        text: draft.title,
        selection: TextSelection.collapsed(offset: draft.title.length),
      );
    }

    final flowState = ref.watch(adFormControllerProvider(AdFormMode.create));

    final showErrors = flowState.attempted.contains(flowState.index);

    final validation = AdFormValidator.basic(draft);
    final titleError = showErrors ? validation.fieldErrors['title'] : null;

    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        /// ---------------- TITLE ----------------
        const SectionTitle(title: 'Title *'),
        const SizedBox(height: 10),

        TextField(
          controller: _titleCtrl,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          onChanged: _onTitleChanged,
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

        /// ---------------- MEDIA ----------------
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
            final categoriesState = ref.read(categoriesControllerProvider);

            CategoryNode? parentNode;

            if (draft.categoryId != null) {
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
