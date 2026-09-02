import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_actions_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/scaffold_shell.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/ad_submit_success_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/create_ad_steps.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/widgets/save_draft_bottom_sheet.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_dirty_checker.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_payload.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_form_step_runner.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/cancel_action.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_schema_provider.dart';
import 'package:africaonlinestores/features/ads/shared/utils/ad_failure_message.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _initializing = true;

  bool get _requiresPreload => widget.draftId != null || widget.adId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadInitialDraft());
    });
  }

  Future<void> _loadInitialDraft() async {
    if (!mounted) return;
    setState(() => _initializing = true);

    ref.read(adFormControllerProvider(widget.mode).notifier).reset();

    final draftCtrl = ref.read(adDraftControllerProvider.notifier);

    if (widget.draftId != null) {
      await draftCtrl.loadFromDraft(widget.draftId!);
    } else if (widget.adId != null) {
      await draftCtrl.loadFromMyAd(widget.adId!);
    } else {
      draftCtrl.createNew();
    }

    if (!mounted) return;
    setState(() => _initializing = false);
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
      if (!AdDirtyChecker.isDirty(draft)) {
        flowCtrl.reset();

        if (mounted) context.pop();

        await Future.microtask(() {
          ref.read(adDraftControllerProvider.notifier).reset();
        });

        return;
      }

      final action = await showModalBottomSheet<CancelAction>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
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

      if (handleFailure(context, res, adStatus: draft.status)) return;

      ctrl.reset();
      ref.read(adDraftControllerProvider.notifier).reset();

      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AdSubmitSuccessDialog(),
      );

      if ((result ?? false) && mounted) {
        context.pop(true);
      }
    } catch (_) {
      if (mounted) ShowSnack(context, 'Failed to submit!').error();
    } finally {
      ctrl.stopPosting();
    }
  }

  bool handleFailure(
    BuildContext context,
    Either<Failure, dynamic> result, {
    String? adStatus,
  }) {
    return result.fold((failure) {
      ShowSnack(context, adFailureMessage(failure, adStatus: adStatus)).error();
      return true;
    }, (_) => false);
  }

  String _formTitle() {
    if (widget.mode == AdFormMode.create) {
      return widget.draftId != null ? 'Edit Draft' : 'Create Ad';
    }
    return 'Edit Ad';
  }

  String _preloadErrorMessage(Object? error) {
    if (error is Failure && error.message.trim().isNotEmpty) {
      return adFailureMessage(error);
    }
    return 'Could not load ad data.';
  }

  Widget _buildPreloadScaffold({String? error, required VoidCallback onRetry}) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_formTitle()),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: error == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return _buildPreloadScaffold(
        onRetry: () => unawaited(_loadInitialDraft()),
      );
    }

    final flowState = ref.watch(adFormControllerProvider(widget.mode));
    final flowCtrl = ref.read(adFormControllerProvider(widget.mode).notifier);
    final draftAsync = ref.watch(adDraftControllerProvider);

    if (_requiresPreload && draftAsync.isLoading) {
      return _buildPreloadScaffold(
        onRetry: () => unawaited(_loadInitialDraft()),
      );
    }

    if (_requiresPreload && draftAsync.hasError) {
      return _buildPreloadScaffold(
        error: _preloadErrorMessage(draftAsync.error),
        onRetry: () => unawaited(_loadInitialDraft()),
      );
    }

    final draft = draftAsync.value ?? const AdDraft(source: DraftSource.create);
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

    if (_requiresPreload &&
        categoryId != null &&
        categoryId.trim().isNotEmpty &&
        schemaAsync.isLoading) {
      return _buildPreloadScaffold(
        onRetry: () => ref.invalidate(adCategorySchemaProvider(categoryId)),
      );
    }

    if (_requiresPreload &&
        categoryId != null &&
        categoryId.trim().isNotEmpty &&
        schemaAsync.hasError) {
      return _buildPreloadScaffold(
        error: 'Could not load the ad category fields.',
        onRetry: () => ref.invalidate(adCategorySchemaProvider(categoryId)),
      );
    }

    const fallbackSchema = AdCategorySchema(
      category: AdCategory(id: '', name: '', isService: false),
      attributes: [],
      pricing: PricingSchema(requirement: PricingRequirement.hidden),
    );

    final schema = schemaAsync.value ?? fallbackSchema;
    final steps = AdFormStepsBuilder.build(schema: schema, mode: widget.mode);
    final index = flowState.index.clamp(0, steps.length - 1);

    final runner = AdFormStepRunner(
      steps: steps,
      index: index,
      draft: draft,
      schema: schema,
    );

    final result = runner.validate();
    final isValid = runner.isValid;

    final bottom = PrimaryButton(
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
    );

    return ScaffoldShell(
      title: _formTitle(),
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
      onStepTapped: _goTo,
      isStepAccessible: flowCtrl.canNavigateTo,
      child: PageView.builder(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (_, i) => steps[i].widget,
      ),
    );
  }
}
