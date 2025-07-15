import 'package:flutter/material.dart';

import '../controllers/place_order.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double total;
  final PlaceOrderController controller;

  const PaymentSummaryCard({
    super.key,
    required this.total,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Grand Total: Sh ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.placeOrder(),
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
