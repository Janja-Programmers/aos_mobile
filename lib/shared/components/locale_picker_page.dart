import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class LocalePickerPage<T extends LocaleOption> extends StatefulWidget {
  const LocalePickerPage({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.onSave,
    this.initialId,
    this.saveButtonText,
  });

  final String title;
  final List<T> items;
  final String? initialId;
  final Future<void> Function(T item) onChanged;
  final Future<void> Function(T item)? onSave;
  final String? saveButtonText;

  @override
  State<LocalePickerPage<T>> createState() => _LocalePickerPageState<T>();
}

class _LocalePickerPageState<T extends LocaleOption>
    extends State<LocalePickerPage<T>> {
  late final TextEditingController _searchController;
  late final List<T> _allItems;

  List<T> _filtered = <T>[];
  String? _selectedId;
  bool _saving = false;
  bool _allowPop = false;
  String? _error;

  bool get _requiresSave => widget.onSave != null;

  bool get _hasUnsavedChanges {
    if (!_requiresSave) return false;
    return (_selectedId ?? '').trim() != (widget.initialId ?? '').trim();
  }

  bool get _canSave =>
      !_saving && _hasUnsavedChanges && (_selectedId?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedId = widget.initialId;
    _allItems = _dedupe(widget.items);
    _filtered = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  List<T> _dedupe(List<T> items) {
    final seen = <String>{};
    final result = <T>[];
    for (final item in items) {
      if (item.canonicalId.isEmpty || !seen.add(item.canonicalId)) continue;
      result.add(item);
    }
    return result;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _allItems
          : _allItems
                .where((item) => item.searchableText.contains(query))
                .toList(growable: false);
    });
  }

  Future<void> _select(T item) async {
    if (_saving) return;
    setState(() {
      _selectedId = item.canonicalId;
      _error = null;
    });

    if (_requiresSave) return;

    setState(() => _saving = true);
    try {
      await widget.onChanged(item);
      if (!mounted) return;
      setState(() {
        _allowPop = true;
        _saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    } catch (error, stackTrace) {
      appLogger.e(
        '[LocalePicker] Selection persistence failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _error = context.l10n.onboarding_preference_error);
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final selected = _allItems
        .where((item) => item.canonicalId == _selectedId)
        .firstOrNull;
    if (selected == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave!(selected);
      if (!mounted) return;
      setState(() {
        _allowPop = true;
        _saving = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    } catch (error, stackTrace) {
      appLogger.e(
        '[LocalePicker] Preference save failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _error = context.l10n.onboarding_preference_error);
    } finally {
      if (mounted && _saving) setState(() => _saving = false);
    }
  }

  Future<void> _handleBlockedPop(bool didPop) async {
    if (didPop || _saving) return;
    final discard = await _confirmDiscardChanges();
    if (!mounted || !discard) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<bool> _confirmDiscardChanges() async {
    final colors = context.appColors;
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(l10n.common_discard_changes_title, style: context.h5),
        content: Text(
          l10n.common_discard_changes_message,
          style: context.pMuted,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_keep_editing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.common_discard,
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return PopScope<Object?>(
      canPop: _allowPop || (!_hasUnsavedChanges && !_saving),
      onPopInvokedWithResult: (didPop, _) =>
          unawaited(_handleBlockedPop(didPop)),
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          title: Text(
            widget.title,
            style: context.h3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: colors.textPrimary),
          elevation: 0,
          toolbarHeight: 72,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: TextField(
                  controller: _searchController,
                  enabled: !_saving,
                  style: context.p.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.common_search,
                    hintStyle: context.pMuted,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.textMuted,
                    ),
                    filled: true,
                    fillColor: colors.elevated,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
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
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    style: context.p.copyWith(color: colors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.common_no_results,
                            style: context.pMuted,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) =>
                            Divider(color: colors.border),
                        itemBuilder: (_, index) {
                          final item = _filtered[index];
                          final selected = item.canonicalId == _selectedId;
                          final subtitle = <String>[
                            if (item.displayCode.isNotEmpty &&
                                item.displayCode != item.displayName)
                              item.displayCode,
                            if (item.symbol?.isNotEmpty ?? false) item.symbol!,
                          ].join(' · ');

                          return ListTile(
                            enabled: !_saving,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                            leading: SizedBox(
                              width: 48,
                              child: Center(
                                child: item.effectiveFlag == null
                                    ? Icon(
                                        Icons.public_rounded,
                                        color: colors.textMuted,
                                      )
                                    : ExcludeSemantics(
                                        child: Text(
                                          item.effectiveFlag!,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                              ),
                            ),
                            title: Text(
                              item.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.pStrong.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: subtitle.isEmpty
                                ? null
                                : Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.pMuted,
                                  ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: colors.primary,
                                  )
                                : null,
                            onTap: () => unawaited(_select(item)),
                          );
                        },
                      ),
              ),
              if (_requiresSave)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: PrimaryButton(
                    text: widget.saveButtonText ?? l10n.common_save,
                    loading: _saving,
                    onPressed: _canSave ? () => unawaited(_save()) : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final sourceIterator = iterator;
    return sourceIterator.moveNext() ? sourceIterator.current : null;
  }
}
