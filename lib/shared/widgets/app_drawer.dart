import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '/core/constants/strings.dart';

import '/features/auth/presentation/auth_provider.dart';

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

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Container(
          color: AppColors.background,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: AppColors.white),
                    margin: EdgeInsets.zero,
                    accountName: Text(
                      user?.fullName ?? "Guest",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    accountEmail: Text(
                      user?.email ?? 'Email',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
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
                  Icons.widgets_outlined,
                  AppStrings.items,
                  1,
                  '/items',
                  extra: user,
                ),
                _buildDrawerItem(
                  context,
                  Icons.inventory_2_outlined,
                  AppStrings.stock,
                  2,
                  '/stock-entry',
                ),
                _buildDrawerItem(
                  context,
                  Icons.receipt_long_outlined,
                  AppStrings.orders,
                  3,
                  '/sales-orders',
                ),
                _buildDrawerItem(
                  context,
                  Icons.local_shipping_outlined,
                  AppStrings.deliveryNote,
                  4,
                  '/delivery-notes',
                ),

                const Spacer(),
                const Divider(),

                SafeArea(
                  top: false,
                  child: DrawerItem(
                    icon: Icons.public,
                    title: "View in website",
                    onTap: () => context.push('/'),
                  ),
                ),
              ],
            ),
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
