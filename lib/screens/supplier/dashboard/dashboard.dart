import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ownashop/features/charts/presentation/chart_card.dart';
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
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 0, onItemSelected: (_) {}),
      subTitle: AppStrings.dashboard,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          /// 👇 Sales Chart Card
          const SalesChartCard(),

          const SizedBox(height: 20),

          /// 👇 Dashboard Section Title
          Text('Quick Access', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 10),

          /// 👇 Dashboard Grid Tiles
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              DashboardTile(
                title: AppStrings.items,
                icon: Icons.inventory_2,
                color: Colors.black,
                onTap: () {
                  if (user != null) context.push('/items', extra: user!);
                },
              ),
              DashboardTile(
                title: AppStrings.stock,
                icon: Icons.inventory,
                color: Colors.black,
                onTap: () => context.push('/stock-entry'),
              ),
              DashboardTile(
                title: AppStrings.orders,
                icon: Icons.receipt_long,
                color: Colors.black,
                onTap: () => context.push('/sales-orders'),
              ),
              DashboardTile(
                title: AppStrings.deliveryNote,
                icon: Icons.local_shipping,
                color: Colors.black,
                onTap: () => context.push('/delivery-notes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
