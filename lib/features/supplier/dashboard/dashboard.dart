import 'package:flutter/material.dart';
// import 'package:sqlite_viewer2/sqlite_viewer.dart';
import '/core/constants/colors.dart';
import '/core/constants/strings.dart';
import '/features/supplier/dashboard/widgets/drawer_item.dart';
import 'widgets/dashboard_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../shared/widgets/main_bar.dart';

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
    return MainBarScaffold(
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
              icon: Icons.monetization_on,
              title: AppStrings.itemPrice,
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
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
              icon: Icons.list_alt,
              title: AppStrings.orders,
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() => _selectedIndex = 5);
                Navigator.pop(context);
                context.push('/web-items');
              },
            ),

            DrawerItem(
              icon: Icons.list_alt,
              title: AppStrings.reports,
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() => _selectedIndex = 5);
                Navigator.pop(context);
                context.push('/web-items');
              },
            ),
            // DrawerItem(
            //   icon: Icons.admin_panel_settings,
            //   title: "Admin Database",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => DatabaseList()),
            //     );
            //   },
            // ),

            // other DrawerItems unchanged...
            const Spacer(),
            const Divider(),
            DrawerItem(
              icon: Icons.web,
              title: "View in website",
              onTap: () {
                context.push('/');
              },
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
      ),
      scaffoldKey: _scaffoldKey,
      subTitle: _sections[_selectedIndex],
      onSave: _handleSave,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2,
          children: [
            DashboardTile(
              title: "Items",
              onTap: () {
                if (user != null) {
                  context.push('/items', extra: user!);
                }
              },
            ),
            DashboardTile(
              title: "Item Price",
              onTap: () {
                if (user != null) {
                  context.push('/items', extra: user!);
                }
              },
            ),
            DashboardTile(title: "Stock", onTap: () => context.push('/stock')),
            DashboardTile(
              title: "Website Items",
              onTap: () => context.push('/web-items'),
            ),
            DashboardTile(title: "Orders"),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    switch (_selectedIndex) {
      case 0:
        // Save dashboard-related data if needed
        break;
      case 1:
        // Save Items
        print('Saving Items...');
        break;
      case 2:
        // Save Item Price
        print('Saving Item Prices...');
        break;
      case 3:
        // Save Stock
        print('Saving Stock...');
        break;
      case 4:
        // Save Website Items
        print('Saving Website Items...');
        break;
      case 5:
        // Save Orders
        print('Saving Orders...');
        break;
      case 6:
        // Save Reports
        print('Saving Reports...');
        break;
      default:
        print('No save action for this section');
    }
  }
}
