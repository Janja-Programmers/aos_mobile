import 'package:flutter/material.dart';

// import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';

/// Shared shell for the Ads list (Home) screen.
///
/// Keeps a consistent AppBar + BottomNav while the screen body swaps based on
/// loading/empty/error/content states.
class AdListScaffold extends StatelessWidget {
  const AdListScaffold({
    super.key,
    required this.header,
    required this.body,
    this.title,
    this.actions,
  });

  final PreferredSizeWidget header;
  final Widget body;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    // final colors = context.appColors;

    return Scaffold(
      appBar: header,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(child: body),
    );
  }
}
