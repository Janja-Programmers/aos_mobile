import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_schema_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

import 'package:africaonlinestores/features/ads/ads_create/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/ads_create/utils/create_ad_payload.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/save_draft_bottom_sheet.dart';
import 'package:africaonlinestores/features/ads/shared/ui/widgets/scaffold_shell.dart';

import 'package:africaonlinestores/features/ads/ads_create/controllers/create_ad_flow_controller.dart';

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

      // Preload data for update
      // if (widget.adId != null) {
      //   ref.read(
      //     adDraftControllerProvider.notifier,
      //   ); //TODO: Functionality for loadForEdit(widget.adId!);
      // }

      //  final draftCtrl = ref.read(adDraftControllerProvider.notifier);

      // if (widget.draftId != null) {
      //   draftCtrl.loadFromDraft(widget.draftId!);
      // } else if (widget.adId != null) {
      //   draftCtrl.loadFromAd(widget.adId!);
      // }
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
     if(mounted)  context.pop;
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
       if(mounted)  context.pop;
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
      Navigator.pop(context);
    }

    if (action == CancelAction.saveAndExit && mounted) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();
      ShowSnack(context, 'Draft saved successfully').success();
         context.pop;
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

      final res = await api.createAd(payload: payload);

      if (res.isLeft && mounted) {
        ShowSnack(context, res.leftOrNull!.message).error();
        return;
      }

      ctrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

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
        .maybeWhen(data: (v) => v, orElse: () => const AdDraft());

    final categoryId = draft.categoryId;

    final schemaAsync = categoryId == null || categoryId.trim().isEmpty
        ? const AsyncValue<AdCategorySchema>.data(
            AdCategorySchema(
              attributes: [],
              pricing: PricingSchema(requirement: PricingRequirement.hidden),
            ),
          )
        : ref.watch(adCategorySchemaProvider(categoryId));


    return schemaAsync.when(
      loading: () => ScaffoldShell(
        title: 'Create Ad',
        currentIndex: flowState.index,
        completed: flowState.completed,
        steps: const ['Basic', 'Details', 'Description', 'Pricing'],
        posting: flowState.posting,
        bottom: const SizedBox.shrink(),
        onBackPressed: () => _handleBack(flowState.index),
        onCancelPressed: () {},
        onStepTapped: (_) {},
        isStepAccessible: (_) => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => ScaffoldShell(
        title: 'Create Ad',
        currentIndex: flowState.index,
        completed: flowState.completed,
        steps: const ['Basic', 'Details', 'Description', 'Pricing'],
        posting: flowState.posting,
        bottom: const SizedBox.shrink(),
        onBackPressed: () => _handleBack(flowState.index),
        onCancelPressed: () {},
        onStepTapped: (_) {},
        isStepAccessible: (_) => false,
        child: const Center(child: Text('Failed to load category schema')),
      ),
      data: (schema) {
        final steps = CreateAdStepsBuilder.build(schema: schema);

        final index = flowState.index;
        final isLast = index == steps.length - 1;

        final bottom = SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: isLast ? 'Post Ad' : 'Continue',
              loading: flowState.posting,
              icon: Icons.arrow_forward,
              onPressed: flowState.posting
                  ? null
                  : () async {
                      final validator = steps[index].validator;
                      final result = validator?.call(draft, schema);

                      if (result != null && !result.isValid) {
                        flowCtrl.markAttempted(index);

                        final firstError = result.fieldErrors.values.first;

                        if (mounted) {
                          ShowSnack(context, firstError).error();
                        }

                        return;
                      }

                      flowCtrl.markCompleted(index);

                      if (!isLast) {
                        await _goTo(index + 1);
                      } else {
                        await _post(draft: draft, schema: schema);
                      }
                    },
            ),
          ),
        );

        return ScaffoldShell(
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
        );
      },
    );
  }
}
