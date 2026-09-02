import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_validator.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DescriptionStep extends ConsumerStatefulWidget {
  const DescriptionStep({super.key, this.mode = AdFormMode.create});

  final AdFormMode mode;

  @override
  ConsumerState<DescriptionStep> createState() => _DescriptionStepState();
}

class _DescriptionStepState extends ConsumerState<DescriptionStep> {
  final _ctrl = TextEditingController();
  bool _initialised = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(adDraftControllerProvider);
    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;

    if (!_initialised) {
      _initialised = true;
      _ctrl.text = draft.description;
    }

    final flowState = ref.watch(adFormControllerProvider(widget.mode));
    final showErrors = flowState.attempted.contains(flowState.index);

    final validation = AdFormValidator.description(draft);
    final error = showErrors ? validation.fieldErrors['description'] : null;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text('Item Description *', style: context.pStrong),
        const SizedBox(height: 10),
        Text(
          'Provide a detailed description of your product so buyers can clearly understand what you are offering.',
          style: context.pMuted,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          maxLines: 10,
          style: context.p,
          onChanged: (v) =>
              ref.read(adDraftControllerProvider.notifier).setDescription(v),
          decoration: InputDecoration(
            hintText: 'Write your description here',
            hintStyle: context.pMuted,
            errorText: error,
          ),
        ),
      ],
    );
  }
}
