import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool selected;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? Colors.black : Colors.black87;
    final iconColor = selected ? Colors.black : Colors.black54;

    return Container(
      decoration:
          selected
              ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              )
              : null,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 6.0, // ↓ Less internal vertical padding
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
