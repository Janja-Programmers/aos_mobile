import 'package:flutter/material.dart';
import 'package:sqlite_viewer2/sqlite_viewer.dart';
import '/core/constants/colors.dart';
import '/core/constants/strings.dart';
import '/features/supplier/dashboard/widgets/drawer_item.dart';
import '/features/supplier/dashboard/widgets/dashboard_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_provider.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AuthProvider authProvider;
  User? user;

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
  void initState() {
    super.initState();
    Future.microtask(() {
      authProvider = context.read<AuthProvider>();
      setState(() {
        user = authProvider.user;
      });
    });
  }

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
                  user?.username ?? AppStrings.sellerPanel,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
            DrawerItem(
              icon: Icons.dashboard,
              title: AppStrings.dashboard,
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
                context.push('/dashboard');
              },
            ),
            DrawerItem(
              icon: Icons.inventory,
              title: AppStrings.items,
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
                if (user != null) {
                  context.push('/items', extra: user!);
                }
              },
            ),
            DrawerItem(
              icon: Icons.store,
              title: AppStrings.stock,
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
                context.push('/stock');
              },
            ),
            DrawerItem(
              icon: Icons.web,
              title: AppStrings.websiteItem,
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
                context.push('/web-items');
              },
            ),
            DrawerItem(
              icon: Icons.admin_panel_settings,
              title: "Admin Database",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DatabaseList()),
                );
              },
            ),

            // other DrawerItems unchanged...
            const Spacer(),
            const Divider(),
            DrawerItem(icon: Icons.account_circle, title: AppStrings.profile),
            DrawerItem(icon: Icons.logout, title: AppStrings.logout),
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
              onTap: () {
                if (user != null) {
                  context.push('/items', extra: user!);
                }
              },
            ),

            DashboardCard(
              title: "Stock",
              icon: Icons.store,
              onTap: () => context.push('/stock'),
            ),
            DashboardCard(
              title: "Website Items",
              icon: Icons.web,
              onTap: () => context.push('/web-items'),
            ),
            DashboardCard(title: "Orders", icon: Icons.shopping_cart),
          ],
        ),
      ),
    );
  }
}
