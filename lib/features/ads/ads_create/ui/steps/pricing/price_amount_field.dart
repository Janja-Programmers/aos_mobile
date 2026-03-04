import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/home/shared/providers/marketplace_provider.dart';

class PriceAmountField extends ConsumerStatefulWidget {
  const PriceAmountField({
    super.key,
    required this.price,
    required this.onChanged,
    this.label = 'Price *',
  });

  final double? price;
  final ValueChanged<double?> onChanged;
  final String label;

  @override
  ConsumerState<PriceAmountField> createState() => _PriceAmountFieldState();
}

class _PriceAmountFieldState extends ConsumerState<PriceAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = ref.watch(marketContextProvider).value;
    final currency = market?.currency ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: context.pStrong),
        const SizedBox(height: 8),

        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: context.p,
          decoration: InputDecoration(
            hintText: 'Enter price',
            hintStyle: context.pMuted,
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: Text(currency, style: context.pStrong),
            ),
          ),
          onChanged: (v) {
            final n = double.tryParse(v.trim());
            widget.onChanged(n);
          },
        ),
      ],
    );
  }
}
