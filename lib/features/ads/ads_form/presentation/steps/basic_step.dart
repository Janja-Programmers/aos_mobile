import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/basic/media_section.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/section_tile.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_validator.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BasicStep extends ConsumerStatefulWidget {
  const BasicStep({super.key, this.mode = AdFormMode.create});

  final AdFormMode mode;

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
    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;

    if (_titleCtrl.text != draft.title) {
      _titleCtrl.value = TextEditingValue(
        text: draft.title,
        selection: TextSelection.collapsed(offset: draft.title.length),
      );
    }

    final flowState = ref.watch(adFormControllerProvider(widget.mode));
    final showErrors = flowState.attempted.contains(flowState.index);

    final validation = AdFormValidator.basic(draft);
    final titleError = showErrors ? validation.fieldErrors['title'] : null;

    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
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
        const SectionTitle(title: 'Location *'),
        const SizedBox(height: 10),
        PickerField(
          value: draft.locationLabel,
          leading: const Icon(Icons.place_outlined),
          placeholder: 'Select your location',
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
        const MediaSection(),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Category *'),
        const SizedBox(height: 10),
        PickerField(
          value: draft.categoryLabel,
          leading: const Icon(Icons.category_outlined),
          placeholder: 'Select a category',
          onTap: () async {
            final res = await context.pushNamed<Map<String, dynamic>>(
              AppRoutes.nSelectCategory,
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
