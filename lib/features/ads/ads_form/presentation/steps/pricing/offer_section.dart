import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/schedule_offer_card.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

class OfferSection extends StatefulWidget {
  const OfferSection({
    super.key,
    required this.price,
    required this.offerPrice,
    required this.startDate,
    required this.endDate,
    this.scheduleOfferDates,
    required this.onOfferPriceChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onScheduleChanged,
  });

  final double? price;
  final double? offerPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? scheduleOfferDates;

  final ValueChanged<double?> onOfferPriceChanged;
  final ValueChanged<DateTime?> onStartChanged;
  final ValueChanged<DateTime?> onEndChanged;
  final ValueChanged<bool> onScheduleChanged;

  @override
  State<OfferSection> createState() => _OfferSectionState();
}

class _OfferSectionState extends State<OfferSection> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.offerPrice?.toString() ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OfferSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusNode.hasFocus) return;

    if (widget.offerPrice != oldWidget.offerPrice) {
      final newText = widget.offerPrice?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.value = _controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
          composing: TextRange.empty,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                final raw = v.trim();

                if (raw.isEmpty) {
                  widget.onOfferPriceChanged(null);
                  widget.onScheduleChanged(false);
                  widget.onStartChanged(null);
                  widget.onEndChanged(null);
                  setState(() {});
                  return;
                }

                final n = double.tryParse(raw);
                widget.onOfferPriceChanged(n);

                if (n == null || n <= 0) {
                  widget.onScheduleChanged(false);
                  widget.onStartChanged(null);
                  widget.onEndChanged(null);
                }

                setState(() {});
              },
            ),

            if (widget.offerPrice != null && widget.offerPrice! > 0) ...[
              const SizedBox(height: 16),
              ScheduleOfferCard(
                enabled: widget.scheduleOfferDates ?? false,
                startDate: widget.startDate,
                endDate: widget.endDate,
                onToggle: (v) {
                  widget.onScheduleChanged(v);

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
