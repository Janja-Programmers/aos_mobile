import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

class CategoryPills extends StatefulWidget {
  const CategoryPills({
    super.key,
    required this.children,
    required this.selectedId,
    required this.onSelect,
    this.parentLabel,
  });

  final List<CategoryNode> children;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final String? parentLabel;

  @override
  State<CategoryPills> createState() => _CategoryPillsState();
}

class _CategoryPillsState extends State<CategoryPills> {
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
  void didUpdateWidget(covariant CategoryPills oldWidget) {
    super.didUpdateWidget(oldWidget);

    final childrenChanged = oldWidget.children.length != widget.children.length;

    final selectionChanged = oldWidget.selectedId != widget.selectedId;

    if (childrenChanged || selectionChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  int _selectedIndex() {
    if (widget.selectedId == null) return 0;

    final idx = widget.children.indexWhere((c) => c.id == widget.selectedId);

    return idx == -1 ? 0 : idx + 1;
  }

  void _scrollToSelected() {
    final index = _selectedIndex();

    final key = _itemKeys[index];
    final context = key?.currentContext;

    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final listBox =
        _scrollController.position.context.storageContext.findRenderObject()
            as RenderBox?;

    if (box == null || listBox == null) return;

    final itemOffset = box.localToGlobal(Offset.zero, ancestor: listBox).dx;

    final screenWidth = listBox.size.width;

    final targetScrollOffset =
        _scrollController.offset +
        itemOffset -
        (screenWidth / 2) +
        (box.size.width / 2);

    _scrollController.animateTo(
      targetScrollOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 42,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.children.length + 1,
        itemBuilder: (context, i) {
          final isAll = i == 0;

          final id = isAll ? null : widget.children[i - 1].id;

          final label = isAll
              ? (widget.parentLabel != null
                    ? 'All ${widget.parentLabel!.split(' ').first}'
                    : 'All')
              : widget.children[i - 1].name;

          final selected =
              (isAll && widget.selectedId == null) || id == widget.selectedId;

          final key = _itemKeys.putIfAbsent(i, () => GlobalKey());

          return Padding(
            key: key,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              selected: selected,
              onSelected: (_) => widget.onSelect(id),
              backgroundColor: colors.surface,
              selectedColor: colors.primary.withOpacity(.15),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide.none,
              ),
              label: Text(
                label,
                style: context.p.copyWith(
                  color: selected
                      ? colors.primary.withOpacity(.85)
                      : colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
