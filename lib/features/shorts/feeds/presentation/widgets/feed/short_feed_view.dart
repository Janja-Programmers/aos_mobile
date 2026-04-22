import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';

class ShortsFeedView extends StatefulWidget {
  final PageController controller;
  final int itemCount;
  // final int initialPage;

  final ValueChanged<int> onPageChanged;
  final IndexedWidgetBuilder itemBuilder;

  const ShortsFeedView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.onPageChanged,
    required this.itemBuilder,
    // this.initialPage = 0,
  });

  @override
  State<ShortsFeedView> createState() => _ShortsFeedViewState();
}

class _ShortsFeedViewState extends State<ShortsFeedView> {
  // bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    appLogger.i("🟣 ShortsFeedView.initState");
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   /// Ensures first frame consistency (no duplicate triggers)
  //   if (_isFirstBuild) {
  //     _isFirstBuild = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    appLogger.i("🟣 PageView.build | itemCount=${widget.itemCount}");
    return PageView.builder(
      controller: widget.controller,
      scrollDirection: Axis.vertical,
      physics: const PageScrollPhysics(),
      onPageChanged: (index) {
        widget.onPageChanged(index);
        appLogger.i("📱 PAGE CHANGED → index=$index");
      },
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
