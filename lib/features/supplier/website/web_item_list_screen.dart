import 'package:flutter/material.dart';
import 'package:ownashop/features/auth/presentation/auth_provider.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/features/website/prov.dart';

import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/main_bar.dart';

import 'add_website_item_screen.dart';

class WebsiteItemListScreen extends StatefulWidget {
  const WebsiteItemListScreen({super.key});

  @override
  State<WebsiteItemListScreen> createState() => _WebsiteItemListScreenState();
}

class _WebsiteItemListScreenState extends State<WebsiteItemListScreen> {
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await context.read<WebsiteItemProv>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WebsiteItemProv>();
    final user = context.watch<AuthProvider>().user;

    final items =
        provider.items.where((item) => item.owner == user?.username).toList();

    return MainBarScaffold(
      subTitle: 'Website Items',
      scaffoldKey: GlobalKey<ScaffoldState>(),
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      actionButton: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        icon: const Icon(Icons.add, size: 16),
        label: const Text("Create New", style: TextStyle(fontSize: 13)),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const AddWebsiteItemScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final slide = Tween<Offset>(
                  begin: Offset(0, 0.2),
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
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child:
            provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : provider.error != null
                ? Center(child: Text(provider.error!))
                : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      color: AppColors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.itemCode,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Icon(
                          item.published ? Icons.check_circle : Icons.cancel,
                          color: item.published ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
