import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_option_screen.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final PricingSchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Backend says pricing hidden → no pricing UI
    if (schema.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    if (draft == null) return const SizedBox.shrink();

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    final priceType = draft.priceType;
    final price = draft.price;
    final unit = draft.priceUnit;

    final showAmount = typeNeedsAmount(priceType);
    final showUnit = typeNeedsUnit(priceType, schema);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text(
          'Pricing',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),

        // PRICE TYPE
        if (schema.allowedTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PickerField(
              label: 'Price Type',
              required: schema.requirement == PricingRequirement.required,
              value: priceType,
              onTap: () async {
                final picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => SelectOptionScreen(
                      title: 'Price Type',
                      options: schema.allowedTypes,
                      selected: priceType,
                    ),
                  ),
                );

                if (picked == null) return;

                ctrl.setPriceType(picked);

                // Apply backend rules immediately to keep draft valid
                if (typeForbidsAmountAndUnit(picked)) {
                  // Free / Contact: no numeric price, no unit
                  ctrl.setPrice(null);
                  ctrl.setPriceUnit(null);
                } else if (typeNeedsAmount(picked)) {
                  // Fixed/Negotiable: unit depends on service category
                  if (!typeNeedsUnit(picked, schema)) {
                    ctrl.setPriceUnit(null); // goods must not send unit
                  }
                } else {
                  // unknown future types: keep minimal
                  ctrl.setPrice(null);
                  ctrl.setPriceUnit(null);
                }
              },
            ),
          ),

        // OPTIONAL NOTICE
        if (schema.requirement == PricingRequirement.optional &&
            isEmptyStr(priceType))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Pricing is optional for this category.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

        // AMOUNT (Fixed/Negotiable only)
        if (showAmount)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: price?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
              onChanged: (v) {
                final n = double.tryParse(v.trim());
                ctrl.setPrice(n);
              },
            ),
          ),

        // UNIT (services only)
        if (showUnit)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PickerField(
              label: 'Price Unit',
              required: true,
              value: unit,
              onTap: () async {
                final picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => SelectOptionScreen(
                      title: 'Price Unit',
                      options: schema.allowedUnits,
                      selected: unit,
                    ),
                  ),
                );
                if (picked != null) {
                  ctrl.setPriceUnit(picked);
                }
              },
            ),
          ),
      ],
    );
  }
}
