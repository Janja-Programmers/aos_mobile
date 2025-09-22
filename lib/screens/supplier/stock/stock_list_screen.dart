import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/features/stock/providers/all.dart';
import '/shared/widgets/custom_button.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import 'widgets/stock_list_body.dart';

class StockEntryScreen extends StatefulWidget {
  const StockEntryScreen({super.key});

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StockEntryProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      actionButton: CustomButton(
        onPressed: () async {
          final result = await context.push<bool>('/create-stock-entry');

          if (result == true && context.mounted) {
            context.read<StockEntryProvider>().fetchAll();
          }
        },
      ),
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: const Text(
        'Stock Intake',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      scaffoldKey: _scaffoldKey,
      body: const StockListBody(),
    );
  }
}
