import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';

class AdListLoadingView extends StatelessWidget {
  const AdListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Center(
        child: CircularProgressIndicator(color: context.appColors.primary),
      ),
    );
  }
}
