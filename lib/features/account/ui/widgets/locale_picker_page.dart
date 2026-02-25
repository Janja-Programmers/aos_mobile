import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

/// Generic picker page with search.
/// Used for country, language, currency, etc.
class LocalePickerPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const LocalePickerPage({
    super.key,
    required this.title,
    required this.items,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<LocalePickerPage> createState() => _LocalePickerPageState();
}

class _LocalePickerPageState extends State<LocalePickerPage> {
  late final TextEditingController _searchController;
  late final List<Map<String, dynamic>> _allItems;

  List<Map<String, dynamic>> _filtered = [];
  String? _selectedCode;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _selectedCode = widget.initialValue;

    _allItems = _dedupe(widget.items);
    _filtered = _allItems;

    _searchController.addListener(_onSearchChanged);
  }

  /// Remove duplicate codes and invalid entries once.
  List<Map<String, dynamic>> _dedupe(List<Map<String, dynamic>> items) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final it in items) {
      final code = (it['code'] ?? '').toString();
      if (code.isEmpty || seen.contains(code)) continue;

      seen.add(code);
      result.add(it);
    }

    return result;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() => _filtered = _allItems);
      return;
    }

    setState(() {
      _filtered = _allItems.where((it) {
        final label = (it['name'] ?? '').toString().toLowerCase();
        return label.contains(query);
      }).toList();
    });
  }

  void _select(String code) {
    widget.onChanged(code);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(widget.title, style: context.h3),
        iconTheme: IconThemeData(color: colors.textPrimary),
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final it = _filtered[i];
                final code = (it['code'] ?? '').toString();
                final label = (it['name'] ?? '').toString();

                final selected = code == _selectedCode;

                return ListTile(
                  title: Text(label, style: context.p),
                  trailing: selected
                      ? Icon(Icons.check, color: colors.primary)
                      : const SizedBox(),
                  onTap: () {
                    setState(() => _selectedCode = code);
                    _select(code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
