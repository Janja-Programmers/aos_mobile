import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class LocalePickerPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final Future<void> Function(String value)? onSave;
  final String saveButtonText;
  final Widget Function(Map<String, dynamic> item)? leadingBuilder;

  const LocalePickerPage({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.onSave,
    this.saveButtonText = 'Save',
    this.initialValue,
    this.leadingBuilder,
  });

  @override
  State<LocalePickerPage> createState() => _LocalePickerPageState();
}

class _LocalePickerPageState extends State<LocalePickerPage> {
  late final TextEditingController _searchController;
  late final List<Map<String, dynamic>> _allItems;

  List<Map<String, dynamic>> _filtered = [];
  String? _selectedCode;
  bool _saving = false;

  bool get _requiresSave => widget.onSave != null;

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
        final name = (it['name'] ?? '').toString().toLowerCase();
        final display = (it['display'] ?? '').toString().toLowerCase();
        final code = (it['code'] ?? '').toString().toLowerCase();
        final symbol = (it['symbol'] ?? '').toString().toLowerCase();

        return name.contains(query) ||
            display.contains(query) ||
            code.contains(query) ||
            symbol.contains(query);
      }).toList();
    });
  }

  void _select(String code) {
    setState(() => _selectedCode = code);

    if (!_requiresSave) {
      widget.onChanged(code);
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    final code = _selectedCode?.trim();
    if (code == null || code.isEmpty || _saving) return;

    setState(() => _saving = true);

    try {
      if (widget.onSave != null) {
        await widget.onSave!(code);
      } else {
        widget.onChanged(code);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(widget.title, style: context.h3),
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: TextField(
                controller: _searchController,
                style: context.p.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}...',
                  hintStyle: context.pMuted,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textMuted,
                  ),
                  filled: true,
                  fillColor: colors.elevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary, width: 1.2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => Divider(color: colors.border),
                itemBuilder: (_, i) {
                  final it = _filtered[i];

                  final code = (it['code'] ?? '').toString();
                  final label = (it['name'] ?? it['display'] ?? code)
                      .toString();
                  final subtitle = (it['native_name'] ?? it['symbol'] ?? '')
                      .toString()
                      .trim();

                  final selected = code == _selectedCode;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: Center(child: widget.leadingBuilder?.call(it)),
                    ),
                    title: Text(
                      label,
                      style: context.pStrong.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: subtitle.isEmpty
                        ? null
                        : Text(subtitle, style: context.pMuted),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: colors.primary,
                          )
                        : const SizedBox.shrink(),
                    onTap: () => _select(code),
                  );
                },
              ),
            ),
            if (_requiresSave)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: PrimaryButton(
                  text: widget.saveButtonText,
                  loading: _saving,
                  onPressed: _selectedCode == null ? null : _save,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
