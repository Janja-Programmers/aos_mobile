import 'package:flutter/material.dart';

import 'package:africaonlinestores/ui/components/app_search_bar.dart';

typedef SearchTextOf<T> = String Function(T item);
typedef SearchItemBuilder<T> = Widget Function(BuildContext context, T item);

class SearchableListView<T> extends StatefulWidget {
  const SearchableListView({
    super.key,
    required this.items,
    required this.textOf,
    required this.itemBuilder,
    this.searchHint = 'Search here...',
    this.emptyLabel = 'No results.',
    this.header,
    this.separator,
    this.padding = const EdgeInsets.all(16),
    this.searchPadding = const EdgeInsets.only(bottom: 12),
  });

  final List<T> items;
  final SearchTextOf<T> textOf;
  final SearchItemBuilder<T> itemBuilder;

  final String searchHint;
  final String emptyLabel;

  /// Optional content above the search bar (e.g. "All Cities" tile).
  final Widget? header;

  final Widget? separator;

  final EdgeInsets padding;
  final EdgeInsets searchPadding;

  @override
  State<SearchableListView<T>> createState() => _SearchableListViewState<T>();
}

class _SearchableListViewState<T> extends State<SearchableListView<T>> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _matches(String haystack, String needle) {
    if (needle.isEmpty) return true;
    return haystack.toLowerCase().contains(needle.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.text.trim();

    final filtered = q.isEmpty
        ? widget.items
        : widget.items.where((x) => _matches(widget.textOf(x), q)).toList();

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Padding(
            padding: widget.searchPadding,
            child: AppSearchBar(
              controller: _ctrl,
              // for now: text only, keep mic/camera as no-op
              onSubmitted: (_) {},
              // NOTE: AppSearchBar currently has fixed hint "Search here..."
              // If you want custom hint, I can show you the tiny change to AppSearchBar.
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(widget.emptyLabel))
                : ListView.separated(
                    itemCount:
                        filtered.length + (widget.header != null ? 1 : 0),
                    separatorBuilder: (context, index) {
                      return widget.separator ?? const Divider(height: 1);
                    },
                    itemBuilder: (context, index) {
                      // Header at index 0
                      if (widget.header != null && index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [widget.header!, const Divider(height: 1)],
                        );
                      }

                      // Adjust index if header exists
                      final itemIndex = index - (widget.header != null ? 1 : 0);
                      return widget.itemBuilder(context, filtered[itemIndex]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
