import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/create/utils/create_ad_payload.dart';
import 'package:africaonlinestores/features/ads/create/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/ui/components/app_confirm_sheet.dart';

class SaveDraftConfirmSheet extends ConsumerStatefulWidget {
  const SaveDraftConfirmSheet({
    super.key,
    required this.draft,
    required this.schema,
  });

  final AdDraft draft;
  final AdCategorySchema schema;

  @override
  ConsumerState<SaveDraftConfirmSheet> createState() =>
      _SaveDraftConfirmSheetState();
}

class _SaveDraftConfirmSheetState extends ConsumerState<SaveDraftConfirmSheet> {
  bool _saving = false;

  Future<void> _saveDraft() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final payload = CreateAdPayloadBuilder.build(
        d: widget.draft,
        schema: widget.schema,
      );

      final api = ref.read(adsApiProvider);

      final res = await api.saveAdDraft(payload: payload);

      if (!mounted) return;

      if (res.isLeft) {
        if (!mounted) return;
        ShowSnack(context, res.leftOrNull!.message).error();

        setState(() => _saving = false);
        return;
      }

      // Success → close sheet with result
      if (!mounted) return;
      ShowSnack(context, 'Draft saved successfully').success();

      if (mounted) Navigator.pop(context, CancelAction.saveAndExit);
    } catch (e) {
      if (!mounted) return;

      ShowSnack(context, 'Failed to save draft: $e').error();

      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final navigator = Navigator.of(context);

    return AppConfirmSheet(
      icon: Icons.save_outlined,
      iconBg: scheme.primary,
      title: 'Save Draft?',
      message: 'You have unsaved changes. Save this ad and continue later.',
      primaryText: 'Discard',
      secondaryText: _saving ? 'Saving...' : 'Save Draft',
      onPrimary: _saving
          ? () {}
          : () {
              navigator.pop(CancelAction.discard);
            },

      onSecondary: _saving ? () {} : _saveDraft,
    );
  }
}
