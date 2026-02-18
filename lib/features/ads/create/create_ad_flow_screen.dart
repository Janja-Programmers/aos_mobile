import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/providers/ad_schema_provider.dart';

import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

import 'package:africaonlinestores/features/ads/create/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/create/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/create/utils/create_ad_payload.dart';
import 'package:africaonlinestores/features/ads/create/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/create/widgets/save_draft_bottom_sheet.dart';
import 'package:africaonlinestores/features/ads/ui/widgets/scaffold_shell.dart';

import 'package:africaonlinestores/features/ads/create/controllers/create_ad_flow_controller.dart';

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
      if (mounted) Navigator.pop(context);
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

    // If nothing changed → exit silently
    if (!AdDirtyChecker.isDirty(draft)) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      if (mounted) Navigator.pop(context);
      return;
    }

    final action = await showModalBottomSheet<CancelAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SaveDraftConfirmSheet(draft: draft, schema: schema);
      },
    );

    if (!mounted || action == null) return;

    // ---------- DISCARD ----------
    if (action == CancelAction.discard) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      ShowSnack(context, 'Ad Draft discarded').success();

      if (mounted) Navigator.pop(context);
      return;
    }

    // ---------- SAVED ----------
    if (action == CancelAction.saveAndExit) {
      flowCtrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      ShowSnack(context, 'Draft saved successfully').success();

      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _post({
    required AdDraft d,
    required AdCategorySchema schema,
  }) async {
    final ctrl = ref.read(createAdFlowControllerProvider.notifier);

    ctrl.startPosting();

    try {
      final api = ref.read(adsApiProvider);

      final payload = CreateAdPayloadBuilder.build(d: d, schema: schema);

      final res = await api.createAd(payload: payload);

      if (res.isLeft) {
        if (!mounted) return;
        ShowSnack(context, res.leftOrNull!.message).error();
        return;
      }

      if (!mounted) return;

      ctrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ShowSnack(context, 'Failed to submit: $e').error();
    } finally {
      ctrl.stopPosting();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.adId != null;
    final screenTitle = isEditMode ? 'Update Ad' : 'Create Ad';

    /* ---------------- Flow State ---------------- */

    final flowState = ref.watch(createAdFlowControllerProvider);

    final flowCtrl = ref.read(createAdFlowControllerProvider.notifier);

    final index = flowState.index;
    final posting = flowState.posting;
    final completed = flowState.completed;

    /* ---------------- Draft ---------------- */

    final draft =
        ref
            .watch(adDraftControllerProvider)
            .maybeWhen(data: (v) => v, orElse: () => null) ??
        const AdDraft();

    /* ---------------- Schema ---------------- */

    final categoryId = draft.categoryId;

    final schemaAsync = categoryId == null || categoryId.trim().isEmpty
        ? const AsyncValue<AdCategorySchema>.data(
            AdCategorySchema(
              attributes: [],
              pricing: PricingSchema(requirement: PricingRequirement.hidden),
            ),
          )
        : ref.watch(adCategorySchemaProvider(categoryId));

    /* ---------------- UI ---------------- */

    return schemaAsync.when(
      loading: () => ScaffoldShell(
        title: screenTitle,
        currentIndex: index,
        completed: completed,
        steps: const ['Basic'],
        posting: posting,
        bottom: const SizedBox.shrink(),
        onBackPressed: () => _handleBack(index),
        onCancelPressed: () {},
        child: const Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => ScaffoldShell(
        title: screenTitle,
        currentIndex: index,
        completed: completed,
        steps: const ['Basic'],
        posting: posting,
        bottom: const SizedBox.shrink(),
        onBackPressed: () => _handleBack(index),
        onCancelPressed: () {},
        child: Center(child: Text(e.toString())),
      ),

      data: (schema) {
        /* ---------------- Steps ---------------- */

        final steps = CreateAdStepsBuilder.build(schema: schema);

        final labels = steps.map((e) => e.label).toList();

        /* ---------------- Safe Index ---------------- */

        final safeIndex = index.clamp(0, steps.length - 1);

        if (safeIndex != index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              flowCtrl.setIndex(safeIndex);
            }
          });
        }

        final isLast = safeIndex == steps.length - 1;

        /* ---------------- Validation ---------------- */

        final canContinue =
            steps[safeIndex].validator?.call(draft, schema) ?? true;

        /* ---------------- Bottom Button ---------------- */

        final bottom = SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: isLast ? 'Post Ad' : 'Continue',
              loading: posting,
              onPressed: (posting || !canContinue)
                  ? null
                  : () async {
                      flowCtrl.markCompleted(safeIndex);

                      if (!isLast) {
                        await _goTo(safeIndex + 1);
                        return;
                      }

                      await _post(d: draft, schema: schema);
                    },
            ),
          ),
        );

        return ScaffoldShell(
          title: screenTitle,
          currentIndex: safeIndex,
          completed: completed,
          steps: labels,
          posting: posting,
          bottom: bottom,
          onBackPressed: () => _handleBack(safeIndex),
          onCancelPressed: () => _handleCancel(draft: draft, schema: schema),
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
