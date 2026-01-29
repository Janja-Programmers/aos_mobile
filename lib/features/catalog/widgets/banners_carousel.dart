import 'dart:async';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class BannersCarousel extends StatefulWidget {
  const BannersCarousel({
    super.key,
    required this.imageUrls,
    required this.height,
  });

  final List<String?> imageUrls; // should be length 3
  final double height;

  @override
  State<BannersCarousel> createState() => _BannersCarouselState();
}

class _BannersCarouselState extends State<BannersCarousel> {
  final _pageCtrl = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (widget.imageUrls.isEmpty) return;

      _index = (_index + 1) % widget.imageUrls.length;
      _pageCtrl.animateToPage(
        _index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.imageUrls.length,
              onPageChanged: (v) => setState(() => _index = v),
              itemBuilder: (context, i) {
                final url = widget.imageUrls[i];
                return Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border.all(color: colors.border),
                  ),
                  child: url == null
                      ? Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: colors.textMuted,
                            size: 36,
                          ),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageUrls.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? scheme.primary : colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}
