import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/providers/ads_api_provider.dart';

import 'package:africaonlinestores/ui/components/app_bottom_nav.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  String _status = 'Active';
  bool _loading = false;
  List<AOSAdListItem> _items = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ref.read(adsApiProvider).myAds(status: _status);
    if (!mounted) return;
    setState(() => _loading = false);

    res.fold((f) => ShowSnack(context, f.message).error(), (data) {
      final itemsRaw = ((data['data'] ?? const {}) as Map)['items'];
      final list = <AOSAdListItem>[];
      if (itemsRaw is List) {
        for (final e in itemsRaw) {
          if (e is Map) {
            list.add(AOSAdListItem.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      setState(() => _items = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const ['Active', 'Reviewing', 'Draft', 'Declined'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create flow already exists; keep simple.
          ShowSnack(context, 'Use the + (Sell) button to create an Ad.').info();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final s = tabs[i];
                final active = s == _status;
                return ChoiceChip(
                  label: Text(s),
                  selected: active,
                  onSelected: (_) {
                    setState(() => _status = s);
                    _load();
                  },
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: tabs.length,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final ad = _items[i];
                      return _MyAdTile(ad: ad);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _MyAdTile extends StatelessWidget {
  const _MyAdTile({required this.ad});

  final AOSAdListItem ad;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ad.coverImage.isEmpty
                      ? Container(color: colors.surfaceContainerHighest)
                      : Image.network(ad.coverImage, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.locationName,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.price.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      ShowSnack(context, 'Edit coming soon.').info(),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      ShowSnack(context, 'Status update coming soon.').info(),
                  child: const Text('Mark as sold'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
