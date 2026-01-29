import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

class LocalizationSettingsScreen extends ConsumerStatefulWidget {
  const LocalizationSettingsScreen({super.key});

  @override
  ConsumerState<LocalizationSettingsScreen> createState() =>
      _LocalizationSettingsScreenState();
}

class _LocalizationSettingsScreenState
    extends ConsumerState<LocalizationSettingsScreen> {
  String? _country;
  String? _language;
  String? _currency;

  bool _saving = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final _ = ref.watch(localeControllerProvider);
    final bundleAsync = ref.watch(localeBundleProvider);

    // ✅ Riverpod (older) friendly: listen inside build
    ref.listen<AsyncValue<LocalePrefs>>(localeControllerProvider, (prev, next) {
      final prefs = next.maybeWhen(data: (v) => v, orElse: () => null);
      if (prefs == null) return;
      if (_initialized) return;

      setState(() {
        _country = prefs.countryCode;
        _language = prefs.languageCode;
        _currency = prefs.currencyCode;
        _initialized = true;
      });
    });

    // Optional: also use bundle defaults if prefs aren't ready yet
    ref.listen<AsyncValue<LocaleBundle>>(localeBundleProvider, (prev, next) {
      final bundle = next.maybeWhen(data: (v) => v, orElse: () => null);
      if (bundle == null) return;

      if (_country == null) {
        setState(() => _country = bundle.defaultCountryCode);
      }
      if (_language == null) {
        setState(() => _language = bundle.defaultLanguageCode);
      }
      if (_currency == null) {
        setState(() => _currency = bundle.baseCurrencyCode);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language & Region'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // your exi
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.fieldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: bundleAsync.when(
                data: (bundle) {
                  _country ??= bundle.defaultCountryCode;
                  _language ??= bundle.defaultLanguageCode;
                  _currency ??= bundle.baseCurrencyCode;

                  return Column(
                    children: [
                      _Dropdown(
                        label: 'Country',
                        value: _country,
                        items: bundle.countries,
                        onChanged: (v) => setState(() => _country = v),
                      ),
                      const SizedBox(height: 12),
                      _Dropdown(
                        label: 'Language',
                        value: _language,
                        items: bundle.languages,
                        onChanged: (v) => setState(() => _language = v),
                      ),
                      const SizedBox(height: 12),
                      _Dropdown(
                        label: 'Currency',
                        value: _currency,
                        items: bundle.currencies,
                        onChanged: (v) => setState(() => _currency = v),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Failed to load locale options.',
                  style: TextStyle(color: colors.text),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _save(context),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
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
      // Only mark overridden = true when user explicitly selects values from this screen.
      // Country change typically proposes defaults; but here user is explicitly setting all three,
      // so we treat language/currency as overridden.
      await ctrl.setCountry(country);
      await ctrl.setLanguage(language, overridden: true);
      await ctrl.setCurrency(currency, overridden: true);

      // Sync if logged in; controller should no-op gracefully if not authenticated.
      await ctrl.syncToBackend();

      if (mounted) showAppSnack(context, 'Preferences updated.');
    } catch (_) {
      if (mounted) showAppSnack(context, 'Failed to update preferences.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<LocaleOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = items.map((e) => e.code).toSet();
    final safeValue = (value != null && values.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e.code, // ✅ codes only
              child: Text('${e.label} (${e.code})'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
