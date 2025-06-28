import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/strings.dart';
import '/features/auth/domain/user.dart';
import '/features/auth/presentation/auth_provider.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/dashboard_tile.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AuthProvider authProvider;
  User? user;

  final List<String> _sections = [
    AppStrings.dashboard,
    AppStrings.items,
    AppStrings.itemPrice,
    AppStrings.stock,
    AppStrings.websiteItem,
    AppStrings.orders,
    AppStrings.deliveryNote,
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
      drawer: AppDrawer(selectedIndex: 0, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: _sections[_sections.indexOf(AppStrings.dashboard)],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2,
          children: [
            DashboardTile(
              title: AppStrings.items,
              onTap: () {
                if (user != null) {
                  context.push('/items', extra: user!);
                }
              },
            ),
            DashboardTile(
              title: AppStrings.stock,
              onTap: () => context.push('/stock-entry'),
            ),
            DashboardTile(
              title: AppStrings.orders,
              onTap: () => context.push('/sales-orders'),
            ),
            DashboardTile(
              title: AppStrings.deliveryNote,
              onTap: () => context.push('/delivery-notes'),
            ),
          ],
        ),
      ),
    );
  }
}
