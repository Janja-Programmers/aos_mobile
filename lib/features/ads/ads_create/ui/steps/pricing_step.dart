import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/contact_info.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/offer_section.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/service_unit_picker.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/utils/enums.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final AdCategorySchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = schema.pricing;

    final allowedTypes = pricing.allowedTypes;
    final allowedUnits = pricing.allowedUnits;

    /// Schema capabilities
    final supportsServiceUnits = allowedUnits.isNotEmpty;
    final supportsContactPrice = allowedTypes.contains("Contact for price");

    if (pricing.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    if (draft == null) return const SizedBox.shrink();

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    /// Draft state (user choice)
    final isContactMode = draft.priceType == "Contact for price";
    final isFixedPrice = draft.priceType == "Fixed";

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
          PriceAmountField(price: draft.price, onChanged: ctrl.setPrice),

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
            options: allowedTypes,
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
              onStartChanged: (date) =>
                  _showThemedDatePicker(context, date, ctrl.setOfferStart),
              onEndChanged: (date) =>
                  _showThemedDatePicker(context, date, ctrl.setOfferEnd),
              onScheduleChanged: ctrl.setScheduleOfferDates,
            ),
        ],
      ],
    );
  }

  static Future<void> _showThemedDatePicker(
    BuildContext context,
    DateTime? current,
    void Function(DateTime?) onPicked,
  ) async {
    final theme = Theme.of(context);

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }
}
