import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:africaonlinestores/shared/components/app_confirm_sheet.dart';

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
  void _onSavePressed() {
    Navigator.pop(context, CancelAction.saveAndExit);
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
      onPrimary: () {
        navigator.pop(CancelAction.discard);
      },

      secondaryText: isUpdate ? 'Update Draft' : 'Save Draft',
      onSecondary: _onSavePressed,
    );
  }
}
