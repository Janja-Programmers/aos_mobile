import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

class DealsPills extends StatefulWidget {
  const DealsPills({super.key, required this.selected, required this.onSelect});

  final DealType selected;
  final ValueChanged<DealType> onSelect;

  @override
  State<DealsPills> createState() => _DealsPillsState();
}

class _DealsPillsState extends State<DealsPills> {
  static const _types = DealType.values;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(covariant DealsPills oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  int _selectedIndex() {
    return _types.indexOf(widget.selected);
  }

  void _scrollToSelected() {
    final index = _selectedIndex();

    final key = _itemKeys[index];
    final context = key?.currentContext;

    if (context == null) return;

    final box = context.findRenderObject() as RenderBox?;
    final listBox =
        _scrollController.position.context.storageContext.findRenderObject()
            as RenderBox?;

    if (box == null || listBox == null) return;

    final itemOffset = box.localToGlobal(Offset.zero, ancestor: listBox).dx;

    final screenWidth = listBox.size.width;

    final targetOffset =
        _scrollController.offset +
        itemOffset -
        (screenWidth / 2) +
        (box.size.width / 2);

    _scrollController.animateTo(
      targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _label(DealType type) {
    switch (type) {
      case DealType.all:
        return 'All';
      case DealType.deals:
        return 'Deals';
      case DealType.flashSale:
        return 'Flash Sale';
      case DealType.offers:
        return 'Offers';
      case DealType.newProducts:
        return 'New';
    }
  }

  IconData? _icon(DealType type) {
    switch (type) {
      case DealType.deals:
        return Icons.local_offer;
      case DealType.flashSale:
        return Icons.flash_on;
      case DealType.offers:
        return Icons.percent;
      case DealType.newProducts:
        return Icons.new_releases;
      case DealType.all:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 42,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        itemBuilder: (context, i) {
          final type = _types[i];
          final selectedChip = type == widget.selected;

          final icon = _icon(type);

          final key = _itemKeys.putIfAbsent(i, () => GlobalKey());

          return Padding(
            key: key,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              selected: selectedChip,
              onSelected: (_) => widget.onSelect(type),
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide.none,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: selectedChip ? colors.white : colors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _label(type),
                    style: context.p.copyWith(
                      color: selectedChip ? colors.white : colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
