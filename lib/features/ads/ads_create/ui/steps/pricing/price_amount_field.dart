import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class PriceAmountField extends StatelessWidget {
  const PriceAmountField({
    super.key,
    required this.price,
    required this.onChanged,
  });

  final double? price;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text('Price *', style: context.pStrong),
        const SizedBox(height: 8),

        /// Input
        TextFormField(
          initialValue: price?.toString() ?? '',
          keyboardType: TextInputType.number,
          style: context.p,
          decoration: InputDecoration(
            hintText: 'Enter price',
            hintStyle: context.pMuted,
          ),
          onChanged: (v) {
            final n = double.tryParse(v.trim());
            onChanged(n);
          },
        ),
      ],
    );
  }
}
