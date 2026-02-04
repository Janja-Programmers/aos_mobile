import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class AdListLoadingView extends StatelessWidget {
  const AdListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.appColors.primary),
    );
  }
}
