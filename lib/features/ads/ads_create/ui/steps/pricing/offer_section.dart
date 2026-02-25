import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/schedule_offer_card.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class OfferSection extends StatefulWidget {
  const OfferSection({
    super.key,
    required this.price,
    required this.offerPrice,
    required this.startDate,
    required this.endDate,
    required this.onOfferPriceChanged,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final double? price;
  final double? offerPrice;
  final DateTime? startDate;
  final DateTime? endDate;

  final ValueChanged<double?> onOfferPriceChanged;
  final ValueChanged<DateTime?> onStartChanged;
  final ValueChanged<DateTime?> onEndChanged;

  @override
  State<OfferSection> createState() => _OfferSectionState();
}

class _OfferSectionState extends State<OfferSection> {
  bool schedule = false;

  @override
  void initState() {
    super.initState();

    schedule = widget.startDate != null || widget.endDate != null;
  }

  bool get hasError {
    return !isValidOffer(widget.price, widget.offerPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Offer Price (Optional)', style: context.pStrong),
        const SizedBox(height: 10),

        TextFormField(
          initialValue: widget.offerPrice?.toString() ?? '',
          keyboardType: TextInputType.number,
          style: context.p,
          decoration: InputDecoration(
            hintText: 'Enter discounted price',
            hintStyle: context.pMuted,
            errorText: hasError ? 'Offer price must be lower than price' : null,
          ),
          onChanged: (v) {
            final n = double.tryParse(v.trim());
            widget.onOfferPriceChanged(n);
            setState(() {});
          },
        ),

        /// ⏱ Schedule toggle
        if ((widget.offerPrice ?? 0) > 0) ...[
          const SizedBox(height: 16),

          ScheduleOfferCard(
            enabled: schedule,
            startDate: widget.startDate,
            endDate: widget.endDate,

            onToggle: (v) {
              setState(() => schedule = v);

              if (!v) {
                widget.onStartChanged(null);
                widget.onEndChanged(null);
              }
            },

            onStartPicked: widget.onStartChanged,
            onEndPicked: widget.onEndChanged,
          ),
        ],
      ],
    );
  }
}
