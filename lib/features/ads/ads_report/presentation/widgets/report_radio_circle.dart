import 'package:flutter/material.dart';

class ReportRadioCircle extends StatelessWidget {
  const ReportRadioCircle({
    super.key,
    required this.selected,
    required this.color,
  });

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final border = color.withValues(alpha: .6);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: border,
                ),
              ),
            )
          : null,
    );
  }
}
