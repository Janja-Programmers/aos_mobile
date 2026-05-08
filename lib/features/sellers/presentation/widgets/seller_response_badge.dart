import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class SellerResponseBadge extends StatelessWidget {
  const SellerResponseBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.success.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 16, color: colors.success),
          const SizedBox(width: 6),
          Text(
            'Typically replies within 1 hour',
            style: TextStyle(color: colors.success),
          ),
        ],
      ),
    );
  }
}
