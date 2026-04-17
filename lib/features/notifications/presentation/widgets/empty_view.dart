import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class NotificationEmptyView extends StatelessWidget {
  const NotificationEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 48, color: colors.border),
          const SizedBox(height: 12),
          Text('No notifications yet', style: context.p),
        ],
      ),
    );
  }
}
