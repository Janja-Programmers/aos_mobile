import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, color: colors.primary, size: 40),
          ),

          const SizedBox(height: 16),

          const Text(
            "No Results Found",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),

          const SizedBox(height: 8),

          Text(
            "Try searching with different keywords",
            style: TextStyle(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
