import 'package:flutter/material.dart';
import 'package:amani_mall/core/constants/colors.dart';
import 'package:amani_mall/core/constants/strings.dart';
import 'package:amani_mall/features/supplier/dashboard/widgets/drawer_item.dart';
import 'package:amani_mall/features/supplier/dashboard/widgets/dashboard_card.dart';
import 'package:go_router/go_router.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  final List<String> _sections = [
    AppStrings.dashboard,
    AppStrings.items,
    AppStrings.itemPrice,
    AppStrings.stock,
    AppStrings.websiteItem,
    AppStrings.orders,
    AppStrings.reports,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Center(
                child: Text(
                  AppStrings.sellerPanel,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
            ..._sections.asMap().entries.map((entry) {
              return DrawerItem(
                icon: Icons.circle, // Replace with actual icons
                title: entry.value,
                selected: _selectedIndex == entry.key,
                onTap: () {
                  setState(() {
                    _selectedIndex = entry.key;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const Spacer(),
            const Divider(),
            DrawerItem(icon: Icons.account_circle, title: AppStrings.profile),
            DrawerItem(icon: Icons.settings, title: AppStrings.logout),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_sections[_selectedIndex]),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            DashboardCard(
              title: "Items",
              icon: Icons.inventory,
              onTap: () => context.push('/items'),
            ),
            DashboardCard(title: "Prices", icon: Icons.attach_money),
            DashboardCard(title: "Stock", icon: Icons.store),
            DashboardCard(title: "Orders", icon: Icons.shopping_cart),
            DashboardCard(title: "Website Items", icon: Icons.web),
            DashboardCard(title: "Reports", icon: Icons.bar_chart),
          ],
        ),
      ),
    );
  }
}
