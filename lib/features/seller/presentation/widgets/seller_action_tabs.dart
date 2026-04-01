import 'package:africaonlinestores/features/seller/providers/seller_state_controller_provider.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/navigation/seller_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerActionTabs extends ConsumerWidget {
  const SellerActionTabs({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {
            // navigate to edit profile
          },
        ),
        const SizedBox(width: 8),
        _ActionBtn(
          icon: Icons.palette_outlined,
          label: 'Customize',
          onTap: () async {
            final updated = await SellerNavigation.toCustomizeStore(
              context,
              sellerId,
            );

            if (updated == true && context.mounted) {
              await ref.read(sellerStateProvider(sellerId).notifier).load();
            }
          },
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(height: 4),
              Text(label, style: context.p),
            ],
          ),
        ),
      ),
    );
  }
}
