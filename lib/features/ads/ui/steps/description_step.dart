import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/providers/ad_draft_controller.dart';

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
    final draft = ref.watch(adDraftControllerProvider).maybeWhen(data: (v) => v, orElse: () => null);
    if (draft == null) return const SizedBox.shrink();
    if (!_init) {
      _init = true;
      _ctrl.text = draft.description;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          maxLines: 10,
          onChanged: (v) => ref.read(adDraftControllerProvider.notifier).setDescription(v),
          decoration: const InputDecoration(hintText: 'Write your description here'),
        ),
      ],
    );
  }
}
