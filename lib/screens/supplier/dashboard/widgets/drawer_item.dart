import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

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
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.white : Colors.grey[800]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.white : Colors.grey[800],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 1.0,
      ),
      
    );
  }
}
