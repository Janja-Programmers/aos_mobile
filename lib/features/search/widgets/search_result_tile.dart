import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class SearchRecentTile extends StatelessWidget {
  final String text;

  const SearchRecentTile(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      leading: Icon(Icons.search, color: colors.textMuted),
      title: Text(text),
      trailing: Icon(Icons.close, color: colors.textMuted),
    );
  }
}
