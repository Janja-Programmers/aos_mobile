import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/account/ui/widgets/pref_card.dart';
import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/ui/components/buttons/primary_button.dart';

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
        title: Text('Preferences', style: context.h3),
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
                Text('Manage how the app works for you', style: context.p),
                const SizedBox(height: 16),

                PrefCard(
                  leading: Icons.language,
                  title: 'Language',
                  value: languageLabel,
                  description: 'Controls how text appears in the app.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocalePickerPage(
                          title: 'Languages',
                          items: bundle.languages,
                          initialValue: _language,
                          onChanged: (v) => setState(() {
                            _dirty = true;
                            _language = v;
                          }),
                        ),
                      ),
                    );
                  },
                ),

                PrefCard(
                  leading: Icons.location_on,
                  title: 'Country',
                  value: countryLabel,
                  description:
                      'Determines nearby listings and where your ads appear.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocalePickerPage(
                          title: 'Country',
                          items: bundle.countries,
                          initialValue: _country,
                          onChanged: (v) => setState(() {
                            _dirty = true;
                            _country = v;
                          }),
                        ),
                      ),
                    );
                  },
                ),

                PrefCard(
                  leading: Icons.attach_money,
                  title: 'Currency',
                  value: currencyLabel,
                  description:
                      'Used for prices when viewing and posting listings.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocalePickerPage(
                          title: 'Currency',
                          items: bundle.currencies,
                          initialValue: _currency,
                          onChanged: (v) => setState(() {
                            _dirty = true;
                            _currency = v;
                          }),
                        ),
                      ),
                    );
                  },
                ),

                PrefCard(
                  leading: Icons.my_location,
                  leadingColor: scheme.primary,
                  title: 'Use my current location',
                  titleColor: scheme.primary,
                  value: '',
                  showChevron: false,
                  description:
                      'Automatically sets language, country, and currency.',
                  onTap: _saving
                      ? null
                      : () => setState(() {
                          _dirty = true;
                          _useDeviceDefaults(bundle);
                        }),
                ),

                PrimaryButton(
                  text: 'Update',
                  onPressed: _saving ? null : () => _save(context),
                  loading: _saving,
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

  Future<void> _save(BuildContext context) async {
    final country = _country;
    final language = _language;
    final currency = _currency;

    if (country == null || language == null || currency == null) {
      ShowSnack(
        context,
        'Please select country, language and currency.',
      ).error();
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
        ShowSnack(context, 'Preferences updated.').success();
      }
    } catch (_) {
      if (mounted) ShowSnack(context, 'Failed to update preferences.').error();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
