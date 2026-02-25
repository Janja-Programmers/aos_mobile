import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

enum AppCarouselVariant { primary, secondary }

class AppCarouselItem {
  const AppCarouselItem({this.imageUrl, this.gradient, this.overlay});

  final String? imageUrl;
  final Gradient? gradient;
  final Widget? overlay;
}

class AppCarousel extends StatefulWidget {
  const AppCarousel({
    super.key,
    required this.items,
    this.variant = AppCarouselVariant.primary,
    this.autoScrollDuration,
    this.height,
  });

  final List<AppCarouselItem> items;
  final AppCarouselVariant variant;
  final Duration? autoScrollDuration;
  final double? height;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  Duration get _duration {
    if (widget.autoScrollDuration != null) {
      return widget.autoScrollDuration!;
    }

    return widget.variant == AppCarouselVariant.primary
        ? const Duration(seconds: 3)
        : const Duration(seconds: 4);
  }

  double get _height {
    if (widget.height != null) return widget.height!;

    return widget.variant == AppCarouselVariant.primary ? 140 : 140;
  }

  @override
  void initState() {
    super.initState();

    if (widget.items.length > 1) {
      _timer = Timer.periodic(_duration, (_) {
        if (!mounted) return;

        final next = (_index + 1) % widget.items.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        SizedBox(
          height: _height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final item = widget.items[i];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    /// Background
                    if (item.gradient != null)
                      Container(
                        decoration: BoxDecoration(gradient: item.gradient),
                      )
                    else if (item.imageUrl != null)
                      Image.network(item.imageUrl!, fit: BoxFit.cover)
                    else
                      Container(color: colors.surface),

                    /// Optional dark overlay for image variant
                    if (item.imageUrl != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.35),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                    /// Custom overlay slot
                    if (item.overlay != null)
                      Positioned.fill(child: item.overlay!),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// Indicator
        if (widget.items.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (i) {
              final active = i == _index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
      ],
    );
  }
}

List<AppCarouselItem> buildImageCarouselItems(List<String?> urls) {
  return urls
      .where((e) => e != null)
      .map((url) => AppCarouselItem(imageUrl: url))
      .toList();
}
