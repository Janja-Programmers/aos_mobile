import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/my_ads_provider.dart';

import 'package:africaonlinestores/shared/components/cards/widgets/ad_card_body.dart';
import 'package:africaonlinestores/shared/components/cards/widgets/ad_card_image.dart';

class AdPickerBottomSheet extends ConsumerStatefulWidget {
  final Function(String adId) onSelected;

  const AdPickerBottomSheet({super.key, required this.onSelected});

  @override
  ConsumerState<AdPickerBottomSheet> createState() =>
      _AdPickerBottomSheetState();
}

class _AdPickerBottomSheetState extends ConsumerState<AdPickerBottomSheet> {
  final searchController = TextEditingController();
  String query = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(myAdsProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            _header(),
            _searchBar(),
            const SizedBox(height: 10),

            Expanded(
              child: adsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) =>
                    Center(child: Text(e.toString(), style: context.p)),

                data: (ads) {
                  final filtered = _filterAds(ads);

                  if (filtered.isEmpty) return _emptyState();

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final ad = filtered[index];

                      return AdCard(
                        ad: ad,
                        imageHeight: 110,
                        onTap: () {
                          widget.onSelected(ad.id.toString());
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── FILTER LOGIC

  List<AOSAdListItem> _filterAds(List<AOSAdListItem> ads) {
    if (query.trim().isEmpty) return ads;

    final q = query.toLowerCase();

    return ads.where((ad) {
      return ad.title.toLowerCase().contains(q);
    }).toList();
  }

  // ───────────────────────── UI PARTS

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text("Select an item to search or tag", style: context.pStrong),
    );
  }

  Widget _searchBar() {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: searchController,
        onChanged: (v) => setState(() => query = v),
        style: context.p,
        decoration: InputDecoration(
          hintText: "Search your products...",
          hintStyle: context.pMuted,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: colors.textMuted),
          const SizedBox(height: 12),
          Text("No products yet", style: context.p),
          const SizedBox(height: 6),
          Text("Post a product listing first", style: context.pMuted),
        ],
      ),
    );
  }
}

class AdCard extends StatelessWidget {
  final AOSAdListItem ad;
  final VoidCallback onTap;
  final double imageHeight;

  const AdCard({
    super.key,
    required this.ad,
    required this.onTap,
    this.imageHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdCardImage(ad: ad, height: imageHeight),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: AdCardBody(ad: ad),
            ),
          ],
        ),
      ),
    );
  }
}
