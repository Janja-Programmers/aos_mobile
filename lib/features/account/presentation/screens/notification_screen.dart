import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/shared/components/app_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PushNotificationScreen extends ConsumerStatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  ConsumerState<PushNotificationScreen> createState() =>
      _PushNotificationScreenState();
}

class _PushNotificationScreenState
    extends ConsumerState<PushNotificationScreen> {
  bool notifications = true;
  bool sound = false;
  bool vibrate = false;
  bool specialOffers = false;
  bool appUpdates = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: context.h2.copyWith(fontSize: 16)),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  AppSwitchTile(
                    title: 'Dark Mode',
                    value: isDarkMode,
                    onChanged: (val) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
