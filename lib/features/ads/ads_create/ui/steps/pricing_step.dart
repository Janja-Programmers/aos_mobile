import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/contact_info.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/offer_section.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/service_unit_picker.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final PricingSchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schema.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draftAsync = ref.watch(adDraftControllerProvider);
    final draft = draftAsync.value;
    if (draft == null) return const SizedBox.shrink();

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    final isService = schema.isService;
    final allowedTypes = schema.allowedTypes;

    final priceType = draft.priceType;

    final isContact = priceType == 'Contact for price';
    final isFixed = priceType == 'Fixed';
    final isNegotiable = priceType == 'Negotiable';

    // Validate type safely (allow Contact)
    final isValidType = allowedTypes.contains(priceType) || isContact;

    if (!isValidType && allowedTypes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.setPriceType(allowedTypes.first);
      });
    }

    // Cleanup logic (safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (priceType == null) return;

      if (!schema.allowedTypes.contains(priceType)) {
        ctrl.setPriceType(schema.allowedTypes.first);
        return;
      }

      if (priceType == 'Negotiable') {
        ctrl.setOfferPrice(null);
        ctrl.setOfferStart(null);
        ctrl.setOfferEnd(null);
      }

      if (priceType == 'Contact for price') {
        ctrl.setPrice(null);
        ctrl.setPriceUnit(null);
        ctrl.setOfferPrice(null);
        ctrl.setOfferStart(null);
        ctrl.setOfferEnd(null);
      }
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        const SizedBox(height: 6),
        Text('Set Pricing', style: context.h5),
        const SizedBox(height: 16),

        // =========================
        // VISIBILITY TOGGLE
        // =========================
        if (!isService)
          PriceVisibilityToggle(
            priceType: priceType,
            onSpecify: () {
              if (priceType != 'Fixed') {
                ctrl.setPriceType('Fixed');
              }
            },
            onContact: () {
              if (!isContact) {
                ctrl.setPriceType('Contact for price');
              }
            },
          ),

        // =========================
        // CONTACT MODE
        // =========================
        if (isContact) const ContactInfoCard(),

        // =========================
        // SPECIFY MODE
        // =========================
        if (isFixed || isNegotiable)
          PriceAmountField(price: draft.price, onChanged: ctrl.setPrice),

        if (!isContact) ...[
          PriceTypePicker(
            selected: priceType,
            options: allowedTypes,
            onChanged: (value) {
              if (value != priceType) {
                ctrl.setPriceType(value);
              }
            },
          ),

          const SizedBox(height: 20),

          if (isService && (isFixed || isNegotiable)) ...[
            const SizedBox(height: 16),
            ServiceUnitPicker(
              units: schema.allowedUnits,
              selected: draft.priceUnit,
              onChanged: ctrl.setPriceUnit,
            ),
          ],

          const SizedBox(height: 20),

          if (isFixed)
            OfferSection(
              offerPrice: draft.offerPrice,
              price: draft.price,
              startDate: draft.offerStart,
              endDate: draft.offerEnd,
              onOfferPriceChanged: ctrl.setOfferPrice,
              onStartChanged: (date) =>
                  _showThemedDatePicker(context, date, ctrl.setOfferStart),
              onEndChanged: (date) =>
                  _showThemedDatePicker(context, date, ctrl.setOfferEnd),
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
