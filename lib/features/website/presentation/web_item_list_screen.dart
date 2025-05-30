import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'web_item_provider.dart';
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
    await context.read<WebsiteItemProvider>().loadAllWebsiteItems();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WebsiteItemProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Website Items')),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child:
            provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : provider.error != null
                ? Center(child: Text(provider.error!))
                : ListView.builder(
                  itemCount: provider.websiteItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.websiteItems[index];
                    return ListTile(
                      title: Text(item.websiteDisplayName),
                      subtitle: Text(item.shortDescription ?? ''),
                      trailing: Icon(
                        item.isPublished ? Icons.check_circle : Icons.cancel,
                        color: item.isPublished ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddWebsiteItemScreen()),
            ),
        child: Icon(Icons.add),
      ),
    );
  }
}
