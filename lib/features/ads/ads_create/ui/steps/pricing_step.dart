import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/offer_section.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema});

  final PricingSchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schema.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draft = ref.watch(adDraftControllerProvider).value;
    if (draft == null) return const SizedBox.shrink();

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    final isService = schema.isService;

    final allowedTypes = isService
        ? schema.allowedTypes
        : const ['Fixed', 'Negotiable'];

    final priceType = draft.priceType;

    final isFixed = priceType == 'Fixed';
    final isNegotiable = priceType == 'Negotiable';
    final isContact = priceType == 'Contact for price';

    // Default price type when required
    if (schema.requirement == PricingRequirement.required &&
        (priceType == null || !allowedTypes.contains(priceType))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.setPriceType(allowedTypes.first);
      });
    }

    // ===== Cleanup Enforcement =====
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!allowedTypes.contains(priceType)) {
        ctrl.setPriceType(allowedTypes.first);
        return;
      }

      // Negotiable → clear offer
      if (isNegotiable) {
        ctrl.setOfferPrice(null);
        ctrl.setOfferStart(null);
        ctrl.setOfferEnd(null);
      }

      // Contact → clear everything
      if (isContact) {
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

        // ===== Price Type Picker =====
        PriceTypePicker(
          selected: priceType,
          options: allowedTypes,
          onChanged: (value) {
            ctrl.setPriceType(value);
          },
        ),

        const SizedBox(height: 20),

        // ===== Price Amount =====
        if (isFixed || isNegotiable)
          PriceAmountField(price: draft.price, onChanged: ctrl.setPrice),

        if (isService && (isFixed || isNegotiable)) ...[
          const SizedBox(height: 16),
          _ServiceUnitPicker(
            units: schema.allowedUnits,
            selected: draft.priceUnit,
            onChanged: ctrl.setPriceUnit,
          ),
        ],

        const SizedBox(height: 20),

        // ===== Offer Section (Only Fixed) =====
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

class _ServiceUnitPicker extends StatelessWidget {
  const _ServiceUnitPicker({
    required this.units,
    required this.selected,
    required this.onChanged,
  });

  final List<String> units;
  final String? selected;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: const InputDecoration(labelText: 'Price Unit'),
      items: units
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
