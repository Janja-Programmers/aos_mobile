import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/all.dart';

import '/shared/widgets/custom_button.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/stock_list_body.dart';
import 'create_stock_screen.dart';

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
          final result = await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, animation, _) => const CreateStockEntryScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation);

                final fade = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeIn)).animate(animation);

                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: fade, child: child),
                );
              },
            ),
          );

          if (result == true) {
            context.read<StockEntryProvider>().fetchAll();
          }
        },
      ),

      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: 'Stock Intake',
      scaffoldKey: _scaffoldKey,
      body: const StockListBody(),
    );
  }
}
