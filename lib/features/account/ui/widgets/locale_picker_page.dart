import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

/// Picker page with search using your LocaleOption
class LocalePickerPage extends StatefulWidget {
  final String title;
  final List<LocaleOption> items;
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
  late List<LocaleOption> _filteredItems;
  late TextEditingController _searchController;
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCode = widget.initialValue;
    _filteredItems = _dedupe(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  /// Remove duplicates and empty codes
  List<LocaleOption> _dedupe(List<LocaleOption> items) {
    final seen = <String>{};
    final safeItems = <LocaleOption>[];
    for (final it in items) {
      if (it.code.isEmpty) continue;
      if (seen.contains(it.code)) continue;
      seen.add(it.code);
      safeItems.add(it);
    }
    return safeItems;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _dedupe(
        widget.items,
      ).where((it) => it.label.toLowerCase().contains(query)).toList();
    });
  }

  void _onItemSelected(String code) {
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: TextStyle(color: colors.textPrimary)),
          ),
        ],
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
              itemCount: _filteredItems.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final it = _filteredItems[i];
                final selected = it.code == _selectedCode;
                return ListTile(
                  title: Text(it.label, style: context.p),
                  trailing: selected
                      ? Icon(Icons.check, color: colors.primary)
                      : const SizedBox(),
                  onTap: () {
                    setState(() => _selectedCode = it.code);
                    _onItemSelected(it.code);
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
