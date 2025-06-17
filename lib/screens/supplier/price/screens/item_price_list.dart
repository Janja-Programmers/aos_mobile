import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/features/itemPrice/domain/item_price.dart';
import '/features/itemPrice/prov.dart';
import '/features/auth/presentation/auth_provider.dart';

import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/main_bar.dart';

import '../widgets/add_item_price.dart';

class ItemPriceScreen extends StatefulWidget {
  const ItemPriceScreen({super.key});

  @override
  State<ItemPriceScreen> createState() => _ItemPriceScreenState();
}

class _ItemPriceScreenState extends State<ItemPriceScreen> {
  final _searchCtrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemPriceProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ItemPriceProvider>();
    final user = context.read<AuthProvider>().user?.username;

    final list = prov.items.where((p) => p.owner == user).toList();
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered =
        list.where((p) {
          return query.isEmpty || p.itemCode.toLowerCase().contains(query);
        }).toList();

    Widget body;
    if (prov.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (prov.failure != null) {
      body = Center(child: Text(prov.failure!.message));
    } else if (filtered.isEmpty) {
      body = const Center(child: Text('No item prices found'));
    } else {
      body = Column(
        children: [
          // 🔎 search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by Item Code…',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Item Code'),
                const Spacer(),
                Text('${filtered.length} of ${list.length}'),
              ],
            ),
          ),
          const Divider(),
          // list
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final price = filtered[i];
                return ListTile(
                  title: Text(price.itemCode),
                  subtitle: Text(
                    price.priceListRate == null
                        ? '—'
                        : '${price.priceListRate!.toStringAsFixed(2)} KES',
                  ),
                  onTap: () => context.go('/item-price/${price.itemCode}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(price.priceList),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: 'Item Prices',
      actionButton: TextButton.icon(
        icon: const Icon(Icons.add, size: 16),
        label: const Text("Add Price", style: TextStyle(fontSize: 13)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        onPressed: () async {
          final itemPrice = await showModalBottomSheet<ItemPrice>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddItemPriceModal(),
          );

          if (itemPrice != null) {
            // ✅ correct type or null
            // ignore: use_build_context_synchronously
            context.read<ItemPriceProvider>().add(itemPrice);
          }
        },
      ),
      body: body,
    );
  }
}
