import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/strings.dart';

import '/features/auth/domain/user.dart';
import '/features/d_note/prov.dart';
import '/features/invoice/prov.dart';
import '/features/order/prov.dart';
import '../../../features/product/product_provider.dart';
import '/features/stock/providers/all.dart';

import '/screens/auth/auth_provider.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/hero.dart';
import 'widgets/shortcuts.dart';

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

    // Schedule after first frame so context is ready
    Future.microtask(() {
      authProvider = context.read<AuthProvider>();
      final productProvider = context.read<ProductProvider>();
      final stockProvider = context.read<StockEntryProvider>();
      final orderProvider = context.read<SalesOrderProvider>();
      final deliveryProvider = context.read<DeliveryNoteProvider>();
      final invoiceProvider = context.read<SalesInvoiceProvider>();

      productProvider.fetchProducts();
      stockProvider.fetchAll();
      orderProvider.fetchAll();
      deliveryProvider.fetchAll();
      invoiceProvider.fetchAll();

      setState(() {
        user = authProvider.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final stockProvider = context.watch<StockEntryProvider>();
    final orderProvider = context.watch<SalesOrderProvider>();
    final deliveryProvider = context.watch<DeliveryNoteProvider>();
    final invoiceProvider = context.watch<SalesInvoiceProvider>();

    final products = productProvider.products.length;
    final stockIntakes = stockProvider.entries.length;
    final orders = orderProvider.orders.length;
    final deliveries = deliveryProvider.notes.length;
    final invoices = invoiceProvider.invoices.length;

    Future<void> refreshAll() async {
      await Future.wait([
        productProvider.fetchProducts(),
        stockProvider.fetchAll(),
        orderProvider.fetchAll(),
        deliveryProvider.fetchAll(),
        invoiceProvider.fetchAll(),
      ]);
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 0, onItemSelected: (_) {}),
      subTitle: Text(
        AppStrings.dashboard,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            DashboardHero(bannerImage: const AssetImage('assets/dash.png')),
            const SizedBox(height: 16),
            DashboardShortcuts(
              items: [
                ShortcutItem(
                  title: 'Products',
                  route: '/items',
                  count: products,
                ),
                ShortcutItem(
                  title: 'Stock Intake',
                  route: '/stock-entry',
                  count: stockIntakes,
                ),
                ShortcutItem(
                  title: 'Sales Order',
                  route: '/sales-orders',
                  count: orders,
                ),
                ShortcutItem(
                  title: 'Delivery Note',
                  route: '/delivery-notes',
                  count: deliveries,
                ),
                ShortcutItem(
                  title: 'Sales Invoice',
                  route: '/invoices',
                  count: invoices,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
