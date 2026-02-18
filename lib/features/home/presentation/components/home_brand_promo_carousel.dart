import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';

import 'package:africaonlinestores/features/home/presentation/components/home_brand_models.dart';

/// LEFT: Promo carousel (bottom -> top)
class HomeBrandPromoCarousel extends StatefulWidget {
  const HomeBrandPromoCarousel({
    super.key,
    required this.items,
    required this.borderRadius,
    required this.height,
    this.autoPlay = true,
    this.interval = const Duration(seconds: 4),
    this.animDuration = const Duration(milliseconds: 500),
  });

  final List<HomePromoItem> items;
  final BorderRadius borderRadius;
  final double height;

  final bool autoPlay;
  final Duration interval;
  final Duration animDuration;

  @override
  State<HomeBrandPromoCarousel> createState() => _HomeBrandPromoCarouselState();
}

class _HomeBrandPromoCarouselState extends State<HomeBrandPromoCarousel> {
  late final PageController _pc;
  Timer? _timer;
  int _index = 0;

  List<HomePromoItem> get _items => widget.items;

  @override
  void initState() {
    super.initState();
    _pc = PageController(initialPage: 0);

    if (widget.autoPlay && _items.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        final next = (_index + 1) % _items.length;
        _pc.animateToPage(
          next,
          duration: widget.animDuration,
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) {
            final page = _pc.page ?? 0.0;
            final idx = page.round().clamp(0, _items.length - 1);
            if (idx != _index) setState(() => _index = idx);
          }
          return false;
        },
        child: PageView.builder(
          controller: _pc,
          scrollDirection: Axis.vertical,
          itemCount: _items.length,
          itemBuilder: (context, i) {
            final item = _items[i];
            return _PromoCard(item: item, height: widget.height);
          },
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item, required this.height});

  final HomePromoItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = item.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.withOpacity(0.85), base.withOpacity(0.55)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _PromoPainter(base))),

          // Tag pill
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    item.title,
                    style: context.p.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: context.h5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.subtitle,
                  style: context.p.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _CtaButton(
                  label: item.ctaText,
                  onTap: item.onTapCta,
                  textColor: base,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.onTap,
    required this.textColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.pStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoPainter extends CustomPainter {
  const _PromoPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withOpacity(0.12);
    final p2 = Paint()..color = Colors.white.withOpacity(0.08);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      size.width * 0.60,
      p1,
    );

    canvas.drawCircle(
      Offset(size.width * 1.02, size.height * 1.05),
      size.width * 0.55,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
