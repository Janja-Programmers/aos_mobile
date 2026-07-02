import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/contact_info.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/offer_section.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/service_unit_picker.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final AdCategorySchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = schema.pricing;

    final allowedTypes = pricing.allowedTypes;
    final allowedUnits = pricing.allowedUnits;

    final visiblePriceTypes = allowedTypes
        .where((t) => t != 'Contact for price')
        .toList();

    /// Schema capabilities
    final supportsServiceUnits = allowedUnits.isNotEmpty;
    final supportsContactPrice = allowedTypes.contains('Contact for price');

    if (pricing.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draftAsync = ref.watch(adDraftControllerProvider);

    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    /// Draft state (user choice)
    final isContactMode = draft.priceType == 'Contact for price';
    final isFixedPrice = draft.priceType == 'Fixed';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        const SizedBox(height: 6),
        Text('Set Pricing', style: context.h5),
        const SizedBox(height: 16),

        /// =========================
        /// VISIBILITY TOGGLE
        /// =========================
        if (supportsContactPrice)
          PriceVisibilityToggle(
            priceType: draft.priceType,
            onSpecify: () {
              if (isContactMode) {
                ctrl.setPriceType('Fixed');
              }
            },
            onContact: () {
              if (!isContactMode) {
                ctrl.setPriceType('Contact for price');
                ctrl.setPrice(null);
                ctrl.setPriceUnit(null);
                ctrl.setOfferPrice(null);
              }
            },
          ),

        const SizedBox(height: 20),

        /// =========================
        /// CONTACT MODE
        /// =========================
        if (isContactMode) const ContactInfoCard(),

        /// =========================
        /// SPECIFY PRICE
        /// =========================
        if (!isContactMode) ...[
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

          /// =========================
          /// SERVICE UNIT
          /// =========================
          if (supportsServiceUnits)
            ServiceUnitPicker(
              units: allowedUnits,
              selected: draft.priceUnit,
              onChanged: ctrl.setPriceUnit,
            ),

          const SizedBox(height: 20),

          PriceTypePicker(
            selected: draft.priceType,
            options: visiblePriceTypes,
            onChanged: ctrl.setPriceType,
          ),

          const SizedBox(height: 20),

          /// =========================
          /// OFFER SECTION
          /// =========================
          if (isFixedPrice)
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
    );
  }
}
