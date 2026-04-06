import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';

class HomeSearchScreen extends StatelessWidget {
  const HomeSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final searchCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Search",
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: AppSearchBar(
          controller: searchCtrl,
          readOnly: true,

          /// open search screen normally
          onTap: () => SearchNavigation.toSearchscreen(context),

          /// open search screen and start mic
          onMicTap: () => SearchNavigation.toSearchscreen(context),
          onCameraTap: () => SearchNavigation.toSearchscreen(context),
        ),
      ),
    );
  }
}
