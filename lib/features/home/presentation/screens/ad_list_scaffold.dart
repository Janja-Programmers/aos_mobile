import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: header,
      body: SafeArea(child: body),
    );
  }
}
