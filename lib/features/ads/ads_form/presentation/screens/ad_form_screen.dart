import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/ad_submit_success_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/save_draft_bottom_sheet.dart';

import 'package:africaonlinestores/features/ads/ads_form/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_step_runner.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_schema_provider.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/scaffold_shell.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AdFormScreen extends ConsumerStatefulWidget {
  final AdFormMode mode;
  final String? adId;
  final String? draftId;
  final AdStatus? status;

  const AdFormScreen({
    super.key,
    required this.mode,
    this.adId,
    this.draftId,
    this.status,
  });

  @override
  ConsumerState<AdFormScreen> createState() => _AdFormScreenState();
}

class _AdFormScreenState extends ConsumerState<AdFormScreen> {
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(adFormControllerProvider(widget.mode).notifier).reset();

      final draftCtrl = ref.read(adDraftControllerProvider.notifier);

      if (widget.draftId != null) {
        draftCtrl.loadFromDraft(widget.draftId!);
      } else if (widget.adId != null) {
        draftCtrl.loadFromMyAd(widget.adId!);
      } else {
        draftCtrl.createNew();
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _goTo(int i) async {
    final ctrl = ref.read(adFormControllerProvider(widget.mode).notifier);

    if (!ctrl.canNavigateTo(i)) return;

    ctrl.setIndex(i);

    if (!_pageCtrl.hasClients) return;

    await _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleBack(int index) async {
    final ctrl = ref.read(adFormControllerProvider(widget.mode).notifier);

    if (index == 0) {
      if (mounted) context.pop();
      return;
    }

    ctrl.goBack();

    if (!_pageCtrl.hasClients) return;

    await _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleCancel({
    required AdDraft draft,
    required AdCategorySchema schema,
  }) async {
    final flowCtrl = ref.read(adFormControllerProvider(widget.mode).notifier);

    if (!AdDirtyChecker.isDirty(draft)) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();
      if (mounted) context.pop();
      return;
    }

    final action = await showModalBottomSheet<CancelAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveDraftConfirmSheet(draft: draft, schema: schema),
    );

    if (!mounted || action == null) return;

    final api = ref.read(adsApiProvider);

    if (action == CancelAction.discard) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      ShowSnack(context, 'Ad Draft discarded').success();
      context.pop();
      return;
    }

    if (action == CancelAction.saveAndExit) {
      try {
        final payload = AdFormPayloadBuilder.build(d: draft, schema: schema);

        switch (draft.source) {
          // -------------------------------
          // NEW DIRTY DRAFT → CREATE DRAFT
          // -------------------------------
          case DraftSource.create:
            final res = await api.saveAdDraft(payload: payload);

            if (res.isLeft) {
              if (mounted) ShowSnack(context, res.leftOrNull!.message).error();
              return;
            }
            break;

          // -------------------------------
          // EDITING EXISTING DRAFT
          // -------------------------------
          case DraftSource.draft:
            if (draft.draftId != null) {
              final res = await api.upsertAdDraft(
                draftId: draft.draftId!,
                payload: payload,
              );

              if (res.isLeft) {
                if (mounted) {
                  ShowSnack(context, res.leftOrNull!.message).error();
                }
                return;
              }
            }
            break;

          // -------------------------------
          // EDITING REAL AD → NO DRAFT SAVE
          // -------------------------------
          case DraftSource.edit:
            break;
        }

        flowCtrl.reset();
        ref.read(adDraftControllerProvider.notifier).reset();

        if (mounted) ShowSnack(context, 'Draft saved successfully').success();

        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ShowSnack(context, 'Failed to save draft: $e').error();
        }
      }
    }
  }

  Future<void> _post({
    required AdDraft draft,
    required AdCategorySchema schema,
  }) async {
    final ctrl = ref.read(adFormControllerProvider(widget.mode).notifier);
    ctrl.startPosting();

    try {
      final api = ref.read(adsApiProvider);
      final payload = AdFormPayloadBuilder.build(d: draft, schema: schema);

      final res = switch (draft.source) {
        DraftSource.create => await api.createAd(payload: payload),

        DraftSource.draft => () async {
          final saveRes = await api.upsertAdDraft(
            draftId: draft.draftId!,
            payload: payload,
          );

          if (saveRes.isLeft) return saveRes;

          return await api.submitAdDraft(draftId: draft.draftId!);
        }(),

        DraftSource.edit => await api.updateAd(
          adId: draft.adId!,
          payload: payload,
        ),
      };

      if (!mounted) return;

      if (handleFailure(context, res)) return;

      ctrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AdSubmitSuccessDialog(),
      );

      if (result == true && mounted) {
        context.pop(true);
      }

      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) ShowSnack(context, 'Failed to submit: $e').error();
    } finally {
      ctrl.stopPosting();
    }
  }

  bool handleFailure(BuildContext context, result) {
    final f = result.leftOrNull;
    if (f != null) {
      ShowSnack(context, f.message).error();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(adFormControllerProvider(widget.mode));
    final flowCtrl = ref.read(adFormControllerProvider(widget.mode).notifier);

    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(
          data: (v) => v,
          orElse: () => const AdDraft(source: DraftSource.create),
        );

    final categoryId = draft.categoryId;

    final schemaAsync = categoryId == null || categoryId.trim().isEmpty
        ? const AsyncValue<AdCategorySchema>.data(
            AdCategorySchema(
              category: AdCategory(id: '', name: '', isService: false),
              attributes: [],
              pricing: PricingSchema(requirement: PricingRequirement.hidden),
            ),
          )
        : ref.watch(adCategorySchemaProvider(categoryId));

    const fallbackSchema = AdCategorySchema(
      category: AdCategory(id: '', name: '', isService: false),
      attributes: [],
      pricing: PricingSchema(requirement: PricingRequirement.hidden),
    );

    final schema = schemaAsync.value ?? fallbackSchema;

    final steps = AdFormStepsBuilder.build(schema: schema);

    final index = flowState.index.clamp(0, steps.length - 1);

    final runner = AdFormStepRunner(
      steps: steps,
      index: index,
      draft: draft,
      schema: schema,
    );

    final result = runner.validate();
    final isValid = runner.isValid;

    final bottom = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PrimaryButton(
          text: runner.isLast
              ? (widget.mode == AdFormMode.create ? 'Post Ad' : 'Update Ad')
              : 'Continue',
          loading: flowState.posting,
          icon: runner.isLast ? Icons.check : Icons.arrow_forward,
          onPressed: (flowState.posting || !isValid)
              ? null
              : () async {
                  flowCtrl.markAttempted(index);
                  flowCtrl.markCompleted(index);

                  if (!runner.isLast) {
                    await _goTo(index + 1);
                  } else {
                    await _post(draft: draft, schema: schema);
                  }
                },
          onDisabledTap: () {
            if (!result.isValid) {
              flowCtrl.markAttempted(index);
              final firstError = result.fieldErrors.values.first;
              ShowSnack(context, firstError).error();
            }
          },
        ),
      ),
    );

    return ScaffoldShell(
      title: widget.mode == AdFormMode.create
          ? (widget.draftId != null ? 'Edit Draft' : 'Create Ad')
          : 'Edit Ad',
      currentIndex: index,
      completed: flowState.completed,
      steps: steps.map((e) => e.label).toList(),
      posting: flowState.posting,
      bottom: bottom,
      onBackPressed: () => _handleBack(index),
      onCancelPressed: () => _handleCancel(draft: draft, schema: schema),
      onStepTapped: (i) => _goTo(i),
      isStepAccessible: (i) => flowCtrl.canNavigateTo(i),
      child: PageView.builder(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (_, i) => steps[i].widget,
      ),
    );
  }
}
