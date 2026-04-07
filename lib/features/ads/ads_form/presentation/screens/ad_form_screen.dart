import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_actions_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/ad_submit_success_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/save_draft_bottom_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/scaffold_shell.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_step_runner.dart';

import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_schema_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
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
  bool _isCancelling = false;

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
    if (_isCancelling) return;
    _isCancelling = true;

    final flowCtrl = ref.read(adFormControllerProvider(widget.mode).notifier);

    try {
      // -------------------------------
      // NOT DIRTY → JUST EXIT
      // -------------------------------
      if (!AdDirtyChecker.isDirty(draft)) {
        flowCtrl.reset();

        if (mounted) context.pop();

        await Future.microtask(() {
          ref.read(adDraftControllerProvider.notifier).reset();
        });

        return;
      }

      // -------------------------------
      // ASK USER
      // -------------------------------
      final action = await showModalBottomSheet<CancelAction>(
        context: context,
        isScrollControlled: true,
        backgroundColor: context.appColors.surface,
        builder: (_) => SaveDraftConfirmSheet(draft: draft, schema: schema),
      );

      if (!mounted || action == null) return;

      final actions = ref.read(adActionsControllerProvider);

      final res = await actions.handleCancel(
        draft: draft,
        schema: schema,
        action: action,
      );

      if (!mounted) return;

      if (res.isLeft) {
        ShowSnack(context, res.leftOrNull!.message).error();
        return;
      }

      // -------------------------------
      // UI SIDE EFFECTS (IMPORTANT)
      // -------------------------------
      if (action == CancelAction.discard && mounted) {
        ShowSnack(context, 'Ad Draft discarded').success();
      }

      if (action == CancelAction.saveAndExit && mounted) {
        ShowSnack(context, 'Draft saved successfully').success();
      }

      flowCtrl.reset();

      if (mounted) context.pop();

      await Future.microtask(() {
        ref.read(adDraftControllerProvider.notifier).reset();
      });
    } finally {
      _isCancelling = false;
    }
  }

  Future<void> _post({
    required AdDraft draft,
    required AdCategorySchema schema,
  }) async {
    final ctrl = ref.read(adFormControllerProvider(widget.mode).notifier);
    ctrl.startPosting();

    try {
      final actions = ref.read(adActionsControllerProvider);
      final payload = AdFormPayloadBuilder.build(d: draft, schema: schema);

      final res = await actions.submitAd(draft: draft, payload: payload);

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
    } catch (e) {
      if (mounted) ShowSnack(context, 'Failed to submit!').error();
    } finally {
      ctrl.stopPosting();
    }
  }

  bool handleFailure(BuildContext context, Either<Failure, dynamic> result) {
    return result.fold((failure) {
      ShowSnack(context, failure.message).error();
      return true;
    }, (_) => false);
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
      onCancelPressed: () {
        if (_isCancelling) return;
        _handleCancel(draft: draft, schema: schema);
      },
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
