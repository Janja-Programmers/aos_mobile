import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

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
      final payload = AdFormPayloadBuilder.build(
        d: widget.draft,
        schema: widget.schema,
      );

      final api = ref.read(adsApiProvider);

      final res = switch (widget.draft.source) {
        DraftSource.create => await api.saveAdDraft(payload: payload),

        DraftSource.draft => await api.upsertAdDraft(
          draftId: widget.draft.draftId!,
          payload: payload,
        ),

        DraftSource.edit => null,
      };

      if (!mounted) return;

      if (res != null && res.isLeft) {
        ShowSnack(context, res.leftOrNull!.message).error();
        setState(() => _saving = false);
        return;
      }

      ShowSnack(context, 'Draft saved successfully').success();
      Navigator.pop(context, CancelAction.saveAndExit);
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
    final isUpdate = widget.draft.source == DraftSource.draft;

    return AppConfirmSheet(
      icon: Icons.save_outlined,
      iconBg: scheme.primary,
      title: isUpdate ? 'Update Draft?' : 'Save Draft?',
      message: 'You have unsaved changes. Save this ad and continue later.',
      primaryText: 'Discard',
      onPrimary: _saving
          ? () {}
          : () {
              navigator.pop(CancelAction.discard);
            },
      secondaryText: _saving
          ? 'Saving...'
          : (isUpdate ? 'Update Draft' : 'Save Draft'),

      onSecondary: _saving ? () {} : _saveDraft,
    );
  }
}
