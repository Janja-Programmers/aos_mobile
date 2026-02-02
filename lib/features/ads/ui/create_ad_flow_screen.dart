import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/providers/ad_schema_provider.dart';
import 'package:africaonlinestores/features/ads/ui/steps/basic_step.dart';
import 'package:africaonlinestores/features/ads/ui/steps/details_step.dart';
import 'package:africaonlinestores/features/ads/ui/steps/description_step.dart';
import 'package:africaonlinestores/features/ads/ui/steps/pricing_step.dart';
import 'package:africaonlinestores/features/ads/utils/pricing_rules.dart';
import 'package:africaonlinestores/features/ads/widgets/ad_stepper.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

class CreateAdFlowScreen extends ConsumerStatefulWidget {
  const CreateAdFlowScreen({super.key});

  @override
  ConsumerState<CreateAdFlowScreen> createState() => _CreateAdFlowScreenState();
}

class _CreateAdFlowScreenState extends ConsumerState<CreateAdFlowScreen> {
  final _pageCtrl = PageController();
  int _index = 0;
  bool _posting = false;
  final _completed = <int>{};

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // VALIDATION
  // ---------------------------

  bool _basicValid(AdDraft d) {
    return d.title.trim().isNotEmpty &&
        (d.locationId ?? '').trim().isNotEmpty &&
        (d.categoryId ?? '').trim().isNotEmpty &&
        d.images.isNotEmpty;
  }

  bool _detailsValid(AdDraft d, AdCategorySchema schema) {
    for (final a in schema.attributes) {
      if (!a.required) continue;
      final v = d.attributes[a.key];
      if (v == null) return false;
      if (v is String && v.trim().isEmpty) return false;
      if (v is List && v.isEmpty) return false;
    }
    return true;
  }

  bool _pricingValid(AdDraft d, PricingSchema schema) {
    if (schema.requirement == PricingRequirement.hidden) return true;

    final priceType = d.priceType;

    // Optional and empty -> valid
    if (schema.requirement == PricingRequirement.optional &&
        isEmptyStr(priceType)) {
      return true;
    }

    // Required -> must pick type
    if (schema.requirement == PricingRequirement.required &&
        isEmptyStr(priceType)) {
      return false;
    }

    // Fixed/Negotiable -> price > 0, and unit if service
    if (typeNeedsAmount(priceType)) {
      if (d.price == null || d.price! <= 0) return false;

      if (typeNeedsUnit(priceType, schema)) {
        if (isEmptyStr(d.priceUnit)) return false;
      }
    }

    return true;
  }

  // ---------------------------
  // STEPS
  // ---------------------------

  List<_StepDef> _buildSteps({required AdCategorySchema schema}) {
    final steps = <_StepDef>[];

    steps.add(const _StepDef('Basic', BasicStep()));

    if (schema.attributes.isNotEmpty) {
      steps.add(_StepDef('Details', DetailsStep(schema: schema)));
    }

    steps.add(const _StepDef('Description', DescriptionStep()));

    if (schema.pricing.requirement != PricingRequirement.hidden) {
      steps.add(_StepDef('Pricing', PricingStep(schema: schema.pricing)));
    }

    return steps;
  }

  Future<void> _goTo(int i) async {
    setState(() => _index = i);

    // ✅ Prevent crash when PageView is not mounted/attached
    if (!_pageCtrl.hasClients) return;

    await _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------
  // PAYLOAD (SAFE + BACKEND-ALIGNED)
  // ---------------------------

  Map<String, dynamic> _buildPayload({
    required AdDraft d,
    required AdCategorySchema schema,
  }) {
    final payload = <String, dynamic>{
      'title': d.title.trim(),
      'location': d.locationId,
      'category': d.categoryId,
      'description': d.description.trim(),
      if (!isEmptyStr(d.countryId)) 'country': d.countryId,
      'images': d.images
          .asMap()
          .entries
          .map(
            (e) => {
              'image': e.value.url,
              'is_primary': e.value.isPrimary ? 1 : 0,
              'sort_order': e.key,
            },
          )
          .toList(),
    };

    if (!isEmptyStr(d.videoUrl)) {
      payload['video'] = d.videoUrl;
    }

    // DETAILS child table - SAFE (no firstWhere crash)
    final schemaByKey = {for (final a in schema.attributes) a.key: a};
    final details = <Map<String, dynamic>>[];

    for (final e in d.attributes.entries) {
      final key = e.key;
      final v = e.value;
      final a = schemaByKey[key];

      // stale draft key: skip to avoid crash / backend rejection
      if (a == null) continue;

      final row = <String, dynamic>{'attribute': key};

      switch (a.type) {
        case AdAttributeType.number:
        case AdAttributeType.year:
          row['value_number'] = v;
          break;
        case AdAttributeType.boolean:
          row['value_bool'] = v == true ? 1 : 0;
          break;
        case AdAttributeType.multiselect:
          row['value_json'] = v;
          break;
        case AdAttributeType.date:
          row['value_date'] = v;
          break;
        case AdAttributeType.select:
        case AdAttributeType.text:
        case AdAttributeType.unknown:
          row['value_text'] = v;
          break;
      }

      details.add(row);
    }

    payload['details'] = details;

    // PRICING top-level fields (matches backend)
    final p = schema.pricing;
    final priceType = d.priceType;

    if (p.requirement != PricingRequirement.hidden) {
      // Optional + empty: do not send any price fields
      final optionalEmpty =
          p.requirement == PricingRequirement.optional && isEmptyStr(priceType);

      if (!optionalEmpty) {
        if (!isEmptyStr(priceType)) payload['price_type'] = priceType;
        if (!isEmptyStr(d.currency)) payload['currency'] = d.currency;

        if (typeNeedsAmount(priceType)) {
          if (d.price != null) payload['price'] = d.price;

          if (typeNeedsUnit(priceType, p) && !isEmptyStr(d.priceUnit)) {
            payload['price_unit'] = d.priceUnit;
          }
        } else if (typeForbidsAmountAndUnit(priceType)) {
          payload.remove('price');
          payload.remove('price_unit');
        } else {
          payload.remove('price');
          payload.remove('price_unit');
        }
      }
    }

    return payload;
  }

  // ---------------------------
  // POST
  // ---------------------------

  Future<void> _post({
    required AdDraft d,
    required AdCategorySchema schema,
  }) async {
    setState(() => _posting = true);

    try {
      final api = ref.read(adsApiProvider);
      final payload = _buildPayload(d: d, schema: schema);
      final res = await api.createAd(payload: payload);

      if (res.isLeft) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.leftOrNull!.message)));
        return;
      }

      if (!mounted) return;

      // ✅ IMPORTANT: reset UI state BEFORE resetting draft (prevents RangeError)
      setState(() {
        _index = 0;
        _completed.clear();
      });

      ref.read(adDraftControllerProvider.notifier).reset();

      // Pop after reset; safe because index is now 0
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft =
        ref
            .watch(adDraftControllerProvider)
            .maybeWhen(data: (v) => v, orElse: () => null) ??
        const AdDraft();

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
      loading: () => _ScaffoldShell(
        currentIndex: _index,
        completed: _completed,
        steps: const ['Basic'],
        posting: _posting,
        bottom: const SizedBox.shrink(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _ScaffoldShell(
        currentIndex: _index,
        completed: _completed,
        steps: const ['Basic'],
        posting: _posting,
        bottom: const SizedBox.shrink(),
        child: Center(child: Text(e.toString())),
      ),
      data: (schema) {
        final steps = _buildSteps(schema: schema);
        final labels = steps.map((e) => e.label).toList();

        // ✅ Clamp index synchronously BEFORE steps[_index]
        final safeIndex = _index.clamp(0, steps.length - 1);
        if (safeIndex != _index) {
          _index = safeIndex;
        }

        final isLast = safeIndex == steps.length - 1;
        final currentLabel = steps[safeIndex].label;

        bool canContinue;
        if (safeIndex == 0) {
          canContinue = _basicValid(draft);
        } else if (currentLabel == 'Details') {
          canContinue = _detailsValid(draft, schema);
        } else if (currentLabel == 'Pricing') {
          canContinue = _pricingValid(draft, schema.pricing);
        } else {
          canContinue = true;
        }

        final bottom = SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: isLast ? 'Post Ad' : 'Continue',
              loading: _posting,
              onPressed: (_posting || !canContinue)
                  ? null
                  : () async {
                      _completed.add(safeIndex);

                      if (!isLast) {
                        await _goTo(safeIndex + 1);
                        return;
                      }

                      await _post(d: draft, schema: schema);
                    },
            ),
          ),
        );

        return _ScaffoldShell(
          currentIndex: safeIndex,
          completed: _completed,
          steps: labels,
          posting: _posting,
          bottom: bottom,
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

class _ScaffoldShell extends StatelessWidget {
  const _ScaffoldShell({
    required this.currentIndex,
    required this.completed,
    required this.steps,
    required this.posting,
    required this.child,
    required this.bottom,
  });

  final int currentIndex;
  final Set<int> completed;
  final List<String> steps;
  final bool posting;
  final Widget child;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ad', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: posting ? null : () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (steps.length > 1)
            AdStepper(
              steps: steps,
              currentIndex: currentIndex,
              completed: completed,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: bottom,
    );
  }
}

class _StepDef {
  const _StepDef(this.label, this.widget);
  final String label;
  final Widget widget;
}
