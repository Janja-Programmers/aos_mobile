import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/schedule_offer_card.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

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
  late final TextEditingController _controller;
  bool schedule = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.offerPrice?.toString() ?? '',
    );

    schedule = widget.startDate != null || widget.endDate != null;
  }

  @override
  void didUpdateWidget(covariant OfferSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.offerPrice != oldWidget.offerPrice) {
      _controller.text = widget.offerPrice?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get hasError {
    return !isValidOffer(widget.price, widget.offerPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final prefs = ref.watch(userPreferenceControllerProvider);
        final currency = prefs.currencyCode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offer Price (Optional)', style: context.pStrong),
            const SizedBox(height: 10),

            TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(),
              style: context.p,
              decoration: InputDecoration(
                hintText: 'Enter discounted price',
                hintStyle: context.pMuted,
                errorText: hasError
                    ? 'Offer price must be lower than price'
                    : null,
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(currency, style: context.pStrong),
                ),
              ),
              onChanged: (v) {
                final n = double.tryParse(v.trim());
                widget.onOfferPriceChanged(n);

                if (n == null || n <= 0) {
                  schedule = false;
                  widget.onStartChanged(null);
                  widget.onEndChanged(null);
                }

                setState(() {});
              },
            ),

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
      },
    );
  }
}
