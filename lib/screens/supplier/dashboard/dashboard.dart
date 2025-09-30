import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/features/charts/presentation/chart_card.dart';
import 'package:provider/provider.dart';

import '/core/constants/strings.dart';
import '/features/auth/domain/user.dart';
import '../../auth/auth_provider.dart';

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
      subTitle: Text(
        AppStrings.dashboard,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          /// 👇 Dashboard Grid Tiles (3 per row)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: [
              DashboardTile(
                title: "Dashboard",
                icon: Icons.dashboard,
                highlight: true,
                onTap: () {},
              ),
              DashboardTile(
                title: "Products",
                icon: Icons.shopping_bag,
                onTap: () => context.push('/items'),
              ),
              DashboardTile(
                title: "Stock Intake",
                icon: Icons.warehouse,
                onTap: () => context.push('/stock-entry'),
              ),
              DashboardTile(
                title: "Sales Order",
                icon: Icons.assignment,
                onTap: () => context.push('/sales-orders'),
              ),
              DashboardTile(
                title: "Delivery Note",
                icon: Icons.local_shipping,
                onTap: () => context.push('/delivery-notes'),
              ),
              DashboardTile(
                title: "Sales Invoice",
                icon: Icons.request_quote,
                onTap: () => context.push('/invoices'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 👇 Sales Chart Card moved below shortcuts
          const SalesChartCard(),
        ],
      ),
    );
  }
}
