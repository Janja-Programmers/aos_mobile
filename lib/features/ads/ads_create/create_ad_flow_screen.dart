import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

import 'package:africaonlinestores/features/ads/ads_create/controllers/create_ad_flow_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/ad_submit_success_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/save_draft_bottom_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_payload.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_step_runner.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_schema_provider.dart';
import 'package:africaonlinestores/features/ads/shared/ui/widgets/scaffold_shell.dart';
import 'package:africaonlinestores/features/ads/shared/utils/enums.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/shared/utils/enums.dart';

class CreateAdFlowScreen extends ConsumerStatefulWidget {
  final String? adId;
  final String? draftId;

  const CreateAdFlowScreen({super.key, this.adId, this.draftId});

  @override
  ConsumerState<CreateAdFlowScreen> createState() => _CreateAdFlowScreenState();
}

class _CreateAdFlowScreenState extends ConsumerState<CreateAdFlowScreen> {
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(createAdFlowControllerProvider.notifier).reset();

      final draftCtrl = ref.read(adDraftControllerProvider.notifier);

      if (widget.draftId != null) {
        draftCtrl.loadFromDraft(widget.draftId!);
      } else if (widget.adId != null) {
        draftCtrl.loadFromAd(widget.adId!);
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
    final ctrl = ref.read(createAdFlowControllerProvider.notifier);

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
    final ctrl = ref.read(createAdFlowControllerProvider.notifier);

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
    final flowCtrl = ref.read(createAdFlowControllerProvider.notifier);

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

    if (action == CancelAction.discard && mounted) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();
      ShowSnack(context, 'Ad Draft discarded').success();
      context.pop();
    }

    if (action == CancelAction.saveAndExit && mounted) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();
      ShowSnack(context, 'Draft saved successfully').success();
      context.pop();
    }
  }

  Future<void> _post({
    required AdDraft draft,
    required AdCategorySchema schema,
  }) async {
    final ctrl = ref.read(createAdFlowControllerProvider.notifier);

    ctrl.startPosting();

    try {
      final api = ref.read(adsApiProvider);
      final payload = CreateAdPayloadBuilder.build(d: draft, schema: schema);

      final res = draft.source == DraftSource.existingAd
          ? await api.updateAdDraft(draftId: draft.adId!, payload: payload)
          : await api.createAd(payload: payload);

      if (res.isLeft && mounted) {
        ShowSnack(context, res.leftOrNull!.message).error();
        return;
      }

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

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(createAdFlowControllerProvider);
    final flowCtrl = ref.read(createAdFlowControllerProvider.notifier);

    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(
          data: (v) => v,
          orElse: () => const AdDraft(source: DraftSource.newAd),
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

    final fallbackSchema = const AdCategorySchema(
      category: AdCategory(id: '', name: '', isService: false),
      attributes: [],
      pricing: PricingSchema(requirement: PricingRequirement.hidden),
    );

    final schema = schemaAsync.value ?? fallbackSchema;

    final steps = CreateAdStepsBuilder.build(schema: schema);

    final index = flowState.index.clamp(0, steps.length - 1);

    final runner = CreateAdStepRunner(
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
          text: runner.isLast ? 'Post Ad' : 'Continue',
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

    return Stack(
      children: [
        ScaffoldShell(
          title: 'Create Ad',
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
        ),
      ],
    );
  }
}
