import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final int? count;
  final VoidCallback? onTap;
  final bool highlight;

  const DashboardTile({
    super.key,
    required this.title,
    this.count,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? Colors.green.shade700 : Colors.white;
    final textColor = highlight ? Colors.white : Colors.grey.shade900;
    final borderColor =
        highlight ? Colors.green.shade700 : Colors.grey.shade300;

    return Material(
      color: bg,
      elevation: highlight ? 6 : 1,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (count != null && count! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: highlight ? Colors.white30 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: highlight ? Colors.white : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
