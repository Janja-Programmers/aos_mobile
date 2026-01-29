import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

class PreferenceScreen extends ConsumerStatefulWidget {
  const PreferenceScreen({super.key});

  @override
  ConsumerState<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  String? _country;
  String? _language;
  String? _currency;

  bool _saving = false;

  /// True after the user changes any selection in this screen.
  /// When true, we stop auto-updating fields from providers.
  bool _dirty = false;

  @override
  void initState() {
    super.initState();

    // Hydrate from backend (if logged in) so the screen reflects account prefs.
    // Safe: controller should no-op/return failure when unauthenticated.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(localeControllerProvider.notifier).refreshFromBackend();
      } catch (_) {
        // ignore
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final bundleAsync = ref.watch(localeBundleProvider);

    // ✅ Riverpod (older) friendly: listen inside build
    ref.listen<AsyncValue<LocalePrefs>>(localeControllerProvider, (prev, next) {
      final prefs = next.maybeWhen(data: (v) => v, orElse: () => null);
      if (prefs == null) return;
      if (!mounted) return;

      // Only auto-apply if user hasn't started editing.
      if (_dirty) return;

      setState(() {
        _country = prefs.countryCode;
        _language = prefs.languageCode;
        _currency = prefs.currencyCode;
      });
    });

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: colors.textPrimary,
        ),
        title: Text('Preferences', style: TextStyle(color: colors.textPrimary)),
      ),
      body: bundleAsync.when(
        data: (bundle) {
          // Normalize any existing values to bundle codes (handles cases where
          // a saved preference accidentally contains a label like "Kenya").
          _country =
              _normalizeToCode(bundle.countries, _country) ??
              bundle.defaultCountryCode;
          _language =
              _normalizeToCode(bundle.languages, _language) ??
              bundle.defaultLanguageCode;
          _currency =
              _normalizeToCode(bundle.currencies, _currency) ??
              bundle.baseCurrencyCode;

          final countryLabel = _labelFor(bundle.countries, _country) ?? '—';
          final languageLabel = _labelFor(bundle.languages, _language) ?? '—';
          final currencyLabel = _labelFor(bundle.currencies, _currency) ?? '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage how the app works for you',
                  style: TextStyle(color: colors.textMuted, fontSize: 16),
                ),
                const SizedBox(height: 16),

                _PrefCard(
                  leading: Icons.language,
                  title: 'Language',
                  value: languageLabel,
                  description: 'Controls how text appears in the app.',
                  onTap: () => _openPickerBottomSheet(
                    context,
                    title: 'Language',
                    items: bundle.languages,
                    value: _language,
                    onChanged: (v) => setState(() {
                      _dirty = true;
                      _language = v;
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                _PrefCard(
                  leading: Icons.location_on,
                  title: 'Country',
                  value: countryLabel,
                  description:
                      'Determines nearby listings and where your ads appear.',
                  onTap: () => _openPickerBottomSheet(
                    context,
                    title: 'Country',
                    items: bundle.countries,
                    value: _country,
                    onChanged: (v) => setState(() {
                      _dirty = true;
                      _country = v;
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                _PrefCard(
                  leading: Icons.attach_money,
                  title: 'Currency',
                  value: currencyLabel,
                  description:
                      'Used for prices when viewing and posting listings.',
                  onTap: () => _openPickerBottomSheet(
                    context,
                    title: 'Currency',
                    items: bundle.currencies,
                    value: _currency,
                    onChanged: (v) => setState(() {
                      _dirty = true;
                      _currency = v;
                    }),
                  ),
                ),

                const SizedBox(height: 18),

                _PrefCard(
                  leading: Icons.my_location,
                  leadingColor: scheme.primary,
                  title: 'Use my current location',
                  titleColor: scheme.primary,
                  value: '',
                  showChevron: false,
                  description: '',
                  onTap: _saving
                      ? null
                      : () => setState(() {
                          _dirty = true;
                          _useDeviceDefaults(bundle);
                        }),
                ),

                const SizedBox(height: 10),
                Text(
                  'Automatically sets language, country, and currency.',
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      disabledBackgroundColor: scheme.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _saving ? null : () => _save(context),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load locale options.',
            style: TextStyle(color: colors.textPrimary),
          ),
        ),
      ),
    );
  }

  String? _labelFor(List<LocaleOption> items, String? code) {
    if (code == null) return null;
    for (final it in items) {
      if (it.code == code) return it.label;
    }
    // If code isn't found, it might be a label; show it as-is.
    for (final it in items) {
      if (it.label == code) return it.label;
    }
    return null;
  }

  /// Ensures stored value is a valid option code.
  /// If value matches a label, returns the corresponding code.
  String? _normalizeToCode(List<LocaleOption> items, String? value) {
    if (value == null || value.isEmpty) return null;

    for (final it in items) {
      if (it.code == value) return value;
    }
    for (final it in items) {
      if (it.label == value) return it.code;
    }
    return null;
  }

  void _useDeviceDefaults(LocaleBundle bundle) {
    _country = bundle.defaultCountryCode;
    _language = bundle.defaultLanguageCode;
    _currency = bundle.baseCurrencyCode;
  }

  void _openPickerBottomSheet(
    BuildContext context, {
    required String title,
    required List<LocaleOption> items,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;

    // De-dupe (defensive): avoid Dropdown/List issues if API returns duplicates.
    final seen = <String>{};
    final safeItems = <LocaleOption>[];
    for (final it in items) {
      if (it.code.isEmpty) continue;
      if (seen.contains(it.code)) continue;
      seen.add(it.code);
      safeItems.add(it);
    }

    final normalizedValue = _normalizeToCode(safeItems, value);

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: safeItems.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = safeItems[i];
                    final selected = it.code == normalizedValue;
                    return ListTile(
                      title: Text(it.label),
                      trailing: selected
                          ? const Icon(Icons.check)
                          : const SizedBox(),
                      onTap: () {
                        onChanged(it.code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context) async {
    final country = _country;
    final language = _language;
    final currency = _currency;

    if (country == null || language == null || currency == null) {
      showAppSnack(context, 'Please select country, language and currency.');
      return;
    }

    setState(() => _saving = true);

    final ctrl = ref.read(localeControllerProvider.notifier);

    try {
      await ctrl.setCountry(country);
      await ctrl.setLanguage(language, overridden: true);
      await ctrl.setCurrency(currency, overridden: true);
      await ctrl.syncToBackend();

      if (mounted) {
        setState(() => _dirty = false);
        showAppSnack(context, 'Preferences updated.');
      }
    } catch (_) {
      if (mounted) showAppSnack(context, 'Failed to update preferences.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PrefCard extends StatelessWidget {
  const _PrefCard({
    required this.leading,
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
    this.leadingColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData leading;
  final String title;
  final String value;
  final String description;
  final VoidCallback? onTap;

  final Color? leadingColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (leadingColor ?? scheme.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leading, color: leadingColor ?? scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: titleColor ?? colors.textPrimary,
                            ),
                          ),
                        ),
                        if (showChevron)
                          Icon(Icons.chevron_right, color: colors.textMuted),
                      ],
                    ),
                    if (value.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: colors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
