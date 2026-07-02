import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class SellerResponseBadge extends StatelessWidget {
  const SellerResponseBadge({
    super.key,
    this.responseTimeDisplay,
    this.responseRateDisplay,
  });

  final String? responseTimeDisplay;
  final String? responseRateDisplay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = _displayText;

    if (text == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 16, color: colors.success),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.success),
            ),
          ),
        ],
      ),
    );
  }

  String? get _displayText {
    final time = responseTimeDisplay?.trim();
    if (time != null && time.isNotEmpty) return time;

    final rate = responseRateDisplay?.trim();
    if (rate != null && rate.isNotEmpty) return rate;

    return null;
  }
}
