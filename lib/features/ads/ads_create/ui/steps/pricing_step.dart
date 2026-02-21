import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_amount_field.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/pricing/offer_section.dart';

class PricingStep extends ConsumerWidget {
  const PricingStep({super.key, required this.schema, required this.isService});

  final PricingSchema schema;
  final bool isService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 🔒 Backend says pricing hidden → render nothing
    if (schema.requirement == PricingRequirement.hidden) {
      return const SizedBox.shrink();
    }

    final draft = ref
        .watch(adDraftControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    if (draft == null) return const SizedBox.shrink();

    final ctrl = ref.read(adDraftControllerProvider.notifier);

    final priceType = draft.priceType;

    final needsAmount = typeNeedsAmount(priceType);

    /// When category pricing is required and priceType is empty,
    /// default to Fixed to avoid invalid state.
    if (schema.requirement == PricingRequirement.required &&
        isEmptyStr(priceType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.setPriceType('Fixed');
      });
    }

    if (!schema.isService && isEmptyStr(priceType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.setPriceType('Fixed');
      });
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        const SizedBox(height: 6),
        Text('Set Pricing', style: context.h5),
        const SizedBox(height: 16),

        /// ==============================
        /// 🛠 SERVICE FLOW
        /// ==============================
        if (isService) ...[
          PriceVisibilityToggle(
            priceType: priceType,
            onSpecify: () {
              if (isContactForPrice(priceType) || isEmptyStr(priceType)) {
                ctrl.setPriceType('Fixed');
              }
            },
            onContact: () {
              ctrl.setPriceType('Contact for price');
              ctrl.setPrice(null);
              ctrl.setPriceUnit(null);
              ctrl.setOfferPrice(null);
              ctrl.setOfferStart(null);
              ctrl.setOfferEnd(null);
            },
          ),

          const SizedBox(height: 20),

          if (needsAmount) ...[
            PriceAmountField(price: draft.price, onChanged: ctrl.setPrice),

            const SizedBox(height: 16),

            PriceTypePicker(
              selected: priceType,
              onChanged: (value) {
                ctrl.setPriceType(value);

                if (typeForbidsAmountAndUnit(value)) {
                  ctrl.setPrice(null);
                  ctrl.setPriceUnit(null);
                } else if (!typeNeedsUnit(value, schema)) {
                  ctrl.setPriceUnit(null);
                }
              },
            ),

            const SizedBox(height: 20),

            OfferSection(
              offerPrice: draft.offerPrice,
              price: draft.price,
              startDate: draft.offerStart,
              endDate: draft.offerEnd,
              onOfferPriceChanged: ctrl.setOfferPrice,
              onStartChanged: ctrl.setOfferStart,
              onEndChanged: ctrl.setOfferEnd,
            ),
          ],
        ],

        /// ==============================
        /// 🛍 GOODS FLOW
        /// ==============================
        if (!isService) ...[
          PriceAmountField(price: draft.price, onChanged: ctrl.setPrice),
          const SizedBox(height: 16),

          PriceTypePicker(
            selected: priceType,
            onChanged: (v) => ctrl.setPriceType(v),
          ),

          const SizedBox(height: 20),
          OfferSection(
            price: draft.price,
            offerPrice: draft.offerPrice,
            startDate: draft.offerStart,
            endDate: draft.offerEnd,
            onOfferPriceChanged: ctrl.setOfferPrice,
            onStartChanged: ctrl.setOfferStart,
            onEndChanged: ctrl.setOfferEnd,
          ),
        ],
      ],
    );
  }
}
