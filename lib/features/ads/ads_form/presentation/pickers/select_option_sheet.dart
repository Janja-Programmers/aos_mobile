import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:flutter/material.dart';

class SelectOptionSheet extends StatefulWidget {
  const SelectOptionSheet({
    super.key,
    required this.title,
    required this.options,
    this.selected,
    this.multi = false,
    this.helperText,
  });

  final String title;
  final List<String> options;
  final Object? selected;
  final bool multi;
  final String? helperText;

  @override
  State<SelectOptionSheet> createState() => _SelectOptionSheetState();
}

class _SelectOptionSheetState extends State<SelectOptionSheet> {
  late final TextEditingController _searchController;
  late Set<String> _selectedSet;
  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);

    _selectedSet = widget.multi ? _selectedValues(widget.selected).toSet() : {};
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final helperText = _cleanText(widget.helperText);
    final filteredOptions = _filteredOptions;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.68,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                Text(widget.title, style: context.h5),

                if (helperText != null) ...[
                  const SizedBox(height: 6),
                  Text(helperText, style: context.pMuted),
                ],

                const SizedBox(height: 14),

                TextField(
                  controller: _searchController,
                  style: context.p,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title.toLowerCase()}',
                    hintStyle: context.pMuted,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: _searchController.clear,
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: filteredOptions.isEmpty
                      ? Center(
                          child: Text(
                            'No matching options.',
                            style: context.pMuted,
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: filteredOptions.length,
                          separatorBuilder: (_, _) => const SizedBox.shrink(),
                          itemBuilder: (context, index) {
                            final option = filteredOptions[index];

                            final isSelected = widget.multi
                                ? _selectedSet.contains(option)
                                : widget.selected?.toString() == option;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(option, style: context.p),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: colors.primary)
                                  : null,
                              onTap: () {
                                if (!widget.multi) {
                                  Navigator.of(context).pop(option);
                                  return;
                                }

                                setState(() {
                                  if (_selectedSet.contains(option)) {
                                    _selectedSet.remove(option);
                                  } else {
                                    _selectedSet.add(option);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),

                if (widget.multi) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(_selectedSet.toList());
                      },
                      child: Text('Apply', style: context.p),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> get _filteredOptions {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.options;
    }

    return widget.options
        .where((String option) => option.toLowerCase().contains(query))
        .toList();
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text;

    if (nextQuery == _query) {
      return;
    }

    setState(() {
      _query = nextQuery;
    });
  }

  static List<String> _selectedValues(Object? selected) {
    if (selected == null) {
      return <String>[];
    }

    if (selected is Iterable<Object?>) {
      return selected
          .map((Object? item) => item?.toString().trim() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList();
    }

    return asJsonList(selected)
        .map((Object? item) => item?.toString().trim() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList();
  }

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
