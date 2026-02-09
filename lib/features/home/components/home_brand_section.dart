import 'dart:async';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';

/// Home section:
/// - Left: vertical carousel (3 promos) sliding bottom->top
/// - Right: dynamic category pills (NOT hardcoded)
class HomeBrandSection extends StatelessWidget {
  const HomeBrandSection({
    super.key,
    required this.promos,
    required this.categories,
    this.height = 200,
    this.gap = 12,
  });

  final List<HomePromoItem> promos;
  final List<HomeCategoryItem> categories;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: HomeBrandPromoCarousel(
              items: promos,
              borderRadius: BorderRadius.circular(radius),
              height: height,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: HomeBrandCategoriesCard(
              items: categories,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// LEFT: PROMO CAROUSEL (bottom -> top)
/// ─────────────────────────────────────────────────────────────────────────────

class HomePromoItem {
  const HomePromoItem({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    this.onTapCta,
    this.background = const Color(0xFF6F7CF7),
  });

  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback? onTapCta;
  final Color background;
}

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

  List<HomePromoItem> get _items => widget.items.isEmpty
      ? const [
          HomePromoItem(
            title: 'Top Deals',
            subtitle: 'Best Prices',
            ctaText: 'Shop Now',
          ),
        ]
      : widget.items;

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
          curve: Curves.easeOutCubic,
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
    // Make PageView vertical
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: PageView.builder(
        controller: _pc,
        scrollDirection: Axis.vertical,
        onPageChanged: (i) => setState(() => _index = i),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          return _PromoCard(
            item: _items[i],
            borderRadius: widget.borderRadius,
            height: widget.height,
            dotsCount: _items.length,
            activeIndex: _index,
          );
        },
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.item,
    required this.borderRadius,
    required this.height,
    required this.dotsCount,
    required this.activeIndex,
  });

  final HomePromoItem item;
  final BorderRadius borderRadius;
  final double height;
  final int dotsCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          height: height,
          decoration: BoxDecoration(
            color: item.background,
            borderRadius: borderRadius,
          ),
        ),

        // Subtle illustration
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _PromoPainter())),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              Text(
                item.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 14),

              _ShopNowPill(
                text: item.ctaText,
                onTap: item.onTapCta,
                accent: item.background,
              ),

              const Spacer(),

              // Dots like screenshot
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(dotsCount, (i) {
                    final active = i == activeIndex;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i == dotsCount - 1 ? 0 : 8,
                      ),
                      child: _Dot(active: active),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShopNowPill extends StatelessWidget {
  const _ShopNowPill({required this.text, required this.accent, this.onTap});

  final String text;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: accent.withOpacity(0.95),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : Colors.white.withOpacity(0.4),
      ),
    );
  }
}

class _PromoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withOpacity(0.10);
    final p2 = Paint()..color = Colors.white.withOpacity(0.07);

    final tagW = size.width * 0.62;
    final tagH = size.height * 0.46;

    final tagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.46, size.height * 0.46, tagW, tagH),
      const Radius.circular(28),
    );

    canvas.save();
    canvas.rotate(-0.30);
    canvas.drawRRect(tagRect, p2);
    canvas.restore();

    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.62), 10, p1);

    canvas.drawCircle(
      Offset(size.width * 1.02, size.height * 1.05),
      size.width * 0.55,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// RIGHT: CATEGORIES CARD (dynamic + reusable pill)
/// ─────────────────────────────────────────────────────────────────────────────

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.title,
    required this.icon,
    this.iconBg,
    this.iconFg,
    this.onTapTrailing,
  });

  final String title;
  final IconData icon;

  /// Optional colors (if you want varied category vibes)
  final Color? iconBg;
  final Color? iconFg;

  /// Only trailing arrow is clickable (as requested)
  final VoidCallback? onTapTrailing;
}

class HomeBrandCategoriesCard extends StatelessWidget {
  const HomeBrandCategoriesCard({
    super.key,
    required this.items,
    required this.borderRadius,
    this.header = 'You might be\nlooking for',
    this.maxVisible = 3,
  });

  final List<HomeCategoryItem> items;
  final BorderRadius borderRadius;
  final String header;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor.withOpacity(0.12);
    final bg = Theme.of(context).colorScheme.surface;

    final visible = items.take(maxVisible).toList();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // If the sliver gives a tight height, switch to a more compact layout.
          final compact = c.maxHeight < 190;

          final pad = compact ? 12.0 : 14.0;
          final headerFont = compact ? 18.0 : 20.0;
          final afterHeader = compact ? 8.0 : 10.0;
          final pillGap = compact ? 8.0 : 10.0;

          final content = Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // important for FittedBox
              children: [
                Text(
                  header,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.pStrong.copyWith(
                    fontSize: headerFont,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: afterHeader),

                ...List.generate(visible.length, (i) {
                  final item = visible[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == visible.length - 1 ? 0 : pillGap,
                    ),
                    child: HomeCategoryPill(
                      icon: item.icon,
                      title: item.title,
                      iconBg: item.iconBg,
                      iconFg: item.iconFg,
                      onTapTrailing: item.onTapTrailing,
                      dense: compact, // ✅ compact pill when space is tight
                    ),
                  );
                }),
              ],
            ),
          );

          // ✅ Safety: if text wraps and grows, scale down *only when needed*.
          // This prevents ANY overflow while preserving the design on normal sizes.
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable widget: icon + title + trailing arrow
/// - Only trailing arrow has onTap
class HomeCategoryPill extends StatelessWidget {
  const HomeCategoryPill({
    super.key,
    required this.icon,
    required this.title,
    required this.onTapTrailing,
    this.iconBg,
    this.iconFg,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTapTrailing;
  final Color? iconBg;
  final Color? iconFg;

  /// Smaller paddings/sizes for tight layouts (prevents overflow)
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor.withOpacity(0.10);
    final pillBg = Theme.of(context).dividerColor.withOpacity(0.06);

    final iconBgVar =
        iconBg ?? Theme.of(context).colorScheme.primary.withOpacity(0.12);
    final iconFgVar = iconFg ?? Theme.of(context).colorScheme.primary;

    final vPad = dense ? 8.0 : 12.0;
    final hPad = dense ? 12.0 : 14.0;
    final iconBox = dense ? 32.0 : 36.0;
    final iconSize = dense ? 18.0 : 20.0;
    final gap = dense ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(color: iconBgVar, shape: BoxShape.circle),
            child: Icon(icon, color: iconFgVar, size: iconSize),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Text(
              title,
              maxLines: 1, // ✅ keeps height stable (matches the mock)
              overflow: TextOverflow.ellipsis,
              style: context.pStrong.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          InkWell(
            onTap: onTapTrailing,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(dense ? 4 : 6),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
