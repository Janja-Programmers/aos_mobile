import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_create/controllers/create_ad_flow_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_validator.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

class DescriptionStep extends ConsumerStatefulWidget {
  const DescriptionStep({super.key});

  @override
  ConsumerState<DescriptionStep> createState() => _DescriptionStepState();
}

class _DescriptionStepState extends ConsumerState<DescriptionStep> {
  final _ctrl = TextEditingController();
  bool _init = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    if (draft == null) return const SizedBox.shrink();
    if (!_init) {
      _init = true;
      _ctrl.text = draft.description;
    }

    final flowState = ref.watch(createAdFlowControllerProvider);
    final showErrors = flowState.attempted.contains(flowState.index);
    final validation = CreateAdValidator.description(draft);
    final error = showErrors ? validation.fieldErrors['description'] : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text('Item Description', style: context.pStrong),
        const SizedBox(height: 10),

        Text(
          'Provide a detailed description of your Product to make it easy for buyers to know more about your product.',
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
