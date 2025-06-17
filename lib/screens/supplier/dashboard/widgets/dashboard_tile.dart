import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const DashboardTile({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Color.fromARGB(255, 190, 189, 189), width: 1),
      ),
      elevation: 1,
      margin: EdgeInsets.all(6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.black),
        ),
        onTap: onTap,
      ),
    );
  }
}
