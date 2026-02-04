import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AdListEmptyView extends StatelessWidget {
  const AdListEmptyView({super.key, required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: context.appColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text('No ads available', style: context.h4),
              const SizedBox(height: 8),
              Text(
                'Try refreshing or check again later.',
                style: context.p.copyWith(color: context.appColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
