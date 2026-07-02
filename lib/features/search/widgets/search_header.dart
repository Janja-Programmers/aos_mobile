import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget implements PreferredSizeWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Search',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
