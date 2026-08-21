import 'package:africaonlinestores/shared/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';

class ConnectListShimmer extends StatelessWidget {
  const ConnectListShimmer({super.key, required this.semanticsLabel});

  static const int _rowCount = 8;

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: AppShimmer(
          child: Opacity(
            opacity: isDark ? 0.18 : 0.10,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              itemCount: _rowCount,
              itemBuilder: (context, index) {
                return _ConnectShimmerRow(
                  key: ValueKey<String>('connect_loading_row_$index'),
                  shortTitle: index.isOdd,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectShimmerRow extends StatelessWidget {
  const _ConnectShimmerRow({super.key, required this.shortTitle});

  final bool shortTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          const _ShimmerShape.circle(diameter: 44),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FractionallySizedBox(
                  widthFactor: shortTitle ? 0.52 : 0.66,
                  alignment: AlignmentDirectional.centerStart,
                  child: const _ShimmerShape.line(height: 11),
                ),
                const SizedBox(height: 9),
                const FractionallySizedBox(
                  widthFactor: 0.82,
                  alignment: AlignmentDirectional.centerStart,
                  child: _ShimmerShape.line(height: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

class _ShimmerShape extends StatelessWidget {
  const _ShimmerShape.circle({required double diameter})
    : width = diameter,
      height = diameter,
      shape = BoxShape.circle;

  const _ShimmerShape.line({required this.height})
    : width = double.infinity,
      shape = BoxShape.rectangle;

  final double width;
  final double height;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(height / 2)
            : null,
      ),
    );
  }
}
