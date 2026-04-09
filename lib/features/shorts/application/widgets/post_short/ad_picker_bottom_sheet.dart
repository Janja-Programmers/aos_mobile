import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/widgets/post_short/my_ads_provider.dart';

class AdPickerBottomSheet extends ConsumerWidget {
  final Function(String adId) onSelected;

  const AdPickerBottomSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(myAdsProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: adsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          data: (ads) {
            if (ads.isEmpty) {
              return const Center(
                child: Text(
                  "No ads found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: ads.length,
              itemBuilder: (_, index) {
                final ad = ads[index];

                return GestureDetector(
                  onTap: () {
                    final adId = ad['name'] ?? ad['id'];

                    if (adId == null) {
                      debugPrint('Ad missing ID: $ad');
                      return;
                    }

                    onSelected(adId);
                    Navigator.pop(context);
                  },
                  child: _AdCard(ad: ad),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final Map<String, dynamic> ad;

  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ad['title'] ?? 'Ad',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
