import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/contact_info.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/offer_section.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/service_unit_picker.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final AdCategorySchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = schema.pricing;

    if (pricing.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final allowedTypes = allowedPriceTypesForSchema(pricing);
    final allowedUnits = pricing.allowedUnits;
    final visiblePriceTypes = allowedTypes
        .where((type) => type != 'Contact for price')
        .toList(growable: false);

    final supportsContactPrice = allowedTypes.contains('Contact for price');
    final supportsServiceUnits = allowedUnits.isNotEmpty;

    final draftAsync = ref.watch(adDraftControllerProvider);
    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;
    final ctrl = ref.read(adDraftControllerProvider.notifier);

    final priceType = resolvedPriceType(draft.priceType, pricing);
    final isContactMode = priceType == 'Contact for price';
    final isFixedPrice = priceType == 'Fixed';
    final needsAmount = typeNeedsAmount(priceType);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        const SizedBox(height: 6),
        Text('Set Pricing', style: context.h5),
        const SizedBox(height: 16),

        if (supportsContactPrice)
          PriceVisibilityToggle(
            priceType: priceType,
            onSpecify: () {
              if (!isContactMode) return;
              final next = visiblePriceTypes.contains('Fixed')
                  ? 'Fixed'
                  : (visiblePriceTypes.isEmpty
                        ? null
                        : visiblePriceTypes.first);
              if (next != null) ctrl.setPriceType(next);
            },
            onContact: () {
              if (isContactMode) return;
              ctrl.setPriceType('Contact for price');
              ctrl.setPrice(null);
              ctrl.setPriceUnit(null);
              ctrl.setOfferPrice(null);
            },
          ),

        if (supportsContactPrice) const SizedBox(height: 20),

        if (isContactMode) const ContactInfoCard(),

        if (!isContactMode) ...[
          if (needsAmount) ...[
            PriceAmountField(
              price: draft.price,
              onChanged: (value) {
                ctrl.setPrice(value);

                final offer = draft.offerPrice;
                if (offer != null && value != null && offer >= value) {
                  ctrl.setOfferPrice(null);
                }
              },
            ),
            if (schema.category.isService &&
                needsAmount &&
                allowedUnits.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Fixed or negotiable pricing is unavailable because this service category has no price units configured. Choose another permitted price type.',
                  style: context.pMuted,
                ),
              ),
            if (supportsServiceUnits)
              ServiceUnitPicker(
                units: allowedUnits,
                selected: draft.priceUnit,
                onChanged: ctrl.setPriceUnit,
              ),
            const SizedBox(height: 20),
          ],

          PriceTypePicker(
            selected: priceType,
            options: visiblePriceTypes,
            onChanged: ctrl.setPriceType,
          ),

          if (isFixedPrice) ...[
            const SizedBox(height: 20),
            OfferSection(
              price: draft.price,
              offerPrice: draft.offerPrice,
              startDate: draft.offerStart,
              endDate: draft.offerEnd,
              scheduleOfferDates: draft.scheduleOfferDates ?? false,
              onOfferPriceChanged: ctrl.setOfferPrice,
              onStartChanged: ctrl.setOfferStart,
              onEndChanged: ctrl.setOfferEnd,
              onScheduleChanged: ctrl.setScheduleOfferDates,
            ),
          ],
        ],
      ],
    );
  }
}
