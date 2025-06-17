import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
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

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            margin: EdgeInsets.only(bottom: 2.0, top: 0.0),
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                user?.username ?? AppStrings.sellerPanel,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
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
            Icons.price_change_outlined,
            AppStrings.itemPrice,
            2,
            '/item-price',
            extra: user,
          ),
          _buildDrawerItem(
            context,
            Icons.inventory_2_outlined,
            AppStrings.stock,
            3,
            '/stock',
          ),
          _buildDrawerItem(
            context,
            Icons.shopping_bag_outlined,
            AppStrings.websiteItem,
            4,
            '/web-items',
          ),
          _buildDrawerItem(
            context,
            Icons.receipt_long_outlined,
            AppStrings.orders,
            5,
            '/sales-orders',
          ),
          _buildDrawerItem(
            context,
            Icons.local_shipping_outlined,
            AppStrings.deliveryNote,
            6,
            '/delivery-notes',
          ),

          const Spacer(),
          const Divider(),
          DrawerItem(
            icon: Icons.web,
            title: "View in website",
            onTap: () => context.push('/'),
          ),
          DrawerItem(icon: Icons.account_circle, title: AppStrings.profile),
          DrawerItem(
            icon: Icons.logout,
            title: AppStrings.logout,
            onTap: () {
              authProvider.logout();
              context.push('/');
            },
          ),
        ],
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
