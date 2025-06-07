import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import 'app_bars.dart';

class MainBarScaffold extends StatelessWidget {
  final String subTitle;
  final Widget body;
  final VoidCallback? onSave;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget drawer;

  const MainBarScaffold({
    super.key,
    required this.subTitle,
    required this.body,
    required this.scaffoldKey,
    required this.drawer,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: drawer,
      body: Column(
        children: [
          TopAppBar(
            onHomePressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          const Divider(height: 1, color: AppColors.black),
          SubAppBar(
            title: subTitle,
            onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
            onSavePressed: onSave,
            showSaveButton: false,
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 205, 201, 201)),
          Expanded(child: body),
        ],
      ),
    );
  }
}
