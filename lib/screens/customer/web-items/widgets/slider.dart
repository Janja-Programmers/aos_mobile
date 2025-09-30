import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '/core/utils/formatters.dart';
import '/features/website/slider_prov.dart';

class SliderCarousel extends StatelessWidget {
  const SliderCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final sliderProv = context.watch<SliderProv>();

    if (sliderProv.isLoading) {
      return SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const CircularProgressIndicator(strokeWidth: 3),
          ],
        ),
      );
    }

    if (sliderProv.error != null) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                "Failed to load slider",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => context.read<SliderProv>().loadSlider(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (sliderProv.images.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_size_select_actual_outlined,
                size: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                "No slider images available",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
        ),
        items:
            sliderProv.images.map((imageUrl) {
              final resolvedImgUrl = resolveImageUrl(imageUrl);
              if (resolvedImgUrl == null) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.transparent,
                child: Center(
                  child: Image.network(
                    resolvedImgUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
