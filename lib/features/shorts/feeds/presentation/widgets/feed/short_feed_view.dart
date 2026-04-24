import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ShortsFeedView extends StatefulWidget {
  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageChanged;
  final IndexedWidgetBuilder itemBuilder;

  const ShortsFeedView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.onPageChanged,
    required this.itemBuilder,
  });

  @override
  State<ShortsFeedView> createState() => _ShortsFeedViewState();
}

class _ShortsFeedViewState extends State<ShortsFeedView> {
  int _lastIndex = 0;
  ScrollDirection _direction = ScrollDirection.idle;

  @override
  void initState() {
    super.initState();
    appLogger.i("🟣 ShortsFeedView.initState");
  }

  void _handlePageChanged(int index) {
    /// ─────────────────────────────────────────────
    /// DIRECTION DETECTION (TYPE SAFE)
    /// ─────────────────────────────────────────────
    if (index > _lastIndex) {
      _direction = ScrollDirection.forward;
    } else if (index < _lastIndex) {
      _direction = ScrollDirection.reverse;
    } else {
      _direction = ScrollDirection.idle;
    }

    appLogger.i("📱 PAGE CHANGE | index=$index | direction=$_direction");

    /// ─────────────────────────────────────────────
    /// EMIT INTENT TO SESSION LAYER
    /// ─────────────────────────────────────────────
    widget.onPageChanged(index);

    _lastIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      scrollDirection: Axis.vertical,
      physics: const PageScrollPhysics(),
      onPageChanged: _handlePageChanged,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
