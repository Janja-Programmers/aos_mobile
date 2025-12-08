import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/core/constants/strings.dart';

import '/screens/auth/auth_provider.dart';
import '/screens/supplier/dashboard/widgets/drawer_item.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.65,
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.white),
                margin: const EdgeInsets.only(bottom: 2.0, top: 0.0),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    user?.username ?? AppStrings.sellerPanel,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.black),
                  ),
                ),
              ),
              _buildDrawerItem(
                context,
                Icons.dashboard,
                AppStrings.dashboard,
                0,
                '/dashboard',
              ),
              _buildDrawerItem(
                context,
                Icons.shopping_bag,
                AppStrings.items,
                1,
                '/items',
                extra: user,
              ),
              _buildDrawerItem(
                context,
                Icons.warehouse,
                AppStrings.stock,
                2,
                '/stock-entry',
              ),
              _buildDrawerItem(
                context,
                Icons.assignment,
                AppStrings.orders,
                3,
                '/sales-orders',
              ),
              _buildDrawerItem(
                context,
                Icons.local_shipping,
                AppStrings.deliveryNote,
                4,
                '/delivery-notes',
              ),
              _buildDrawerItem(
                context,
                Icons.request_quote,
                AppStrings.invoice,
                5,
                '/invoices',
              ),

              const Spacer(),
              const Divider(),

              SafeArea(
                top: false,
                child: DrawerItem(
                  icon: Icons.language,
                  title: "Browse Products",
                  onTap: () => context.push('/'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    String route, {
    dynamic extra,
  }) {
    return DrawerItem(
      icon: icon,
      title: title,
      selected: selectedIndex == index,
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);
        context.push(route, extra: extra);
      },
    );
  }
}
