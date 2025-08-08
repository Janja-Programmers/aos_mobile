import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ownashop/core/constants/colors.dart';
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
        child: Shimmer.fromColors(
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
      );
    }

    if (sliderProv.error != null) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            "Failed to load slider",
            style: TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    if (sliderProv.images.isEmpty) {
      return const SizedBox.shrink();
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
