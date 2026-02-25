import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/preferences/user_preference_state.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/account/ui/widgets/pref_card.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

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
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final localizationAsync = ref.watch(localizationControllerProvider);

    final prefsAsync = ref.watch(userPreferenceControllerProvider);

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
      body: localizationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Failed to load locale options.',
            style: TextStyle(color: colors.textPrimary),
          ),
        ),
        data: (localization) {
          // Hydrate from provider only if not editing
          prefsAsync.whenData((prefs) {
            if (_dirty || prefs == null) return;

            _country = prefs.country;
            _language = prefs.language;
            _currency = prefs.currency;
          });

          final countryLabel = _labelFor(localization.countries, _country);
          final languageLabel = _labelFor(localization.languages, _language);
          final currencyLabel = _labelFor(localization.currencies, _currency);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage how the app works for you', style: context.p),
                const SizedBox(height: 16),

                /// Language
                PrefCard(
                  leading: Icons.language,
                  title: 'Language',
                  value: languageLabel ?? '—',
                  description: 'Controls how text appears in the app.',
                  onTap: () => _openPicker(
                    context,
                    title: 'Languages',
                    items: localization.languages,
                    initialValue: _language,
                    onChanged: (v) {
                      setState(() {
                        _dirty = true;
                        _language = v;
                      });
                    },
                  ),
                ),

                /// Country
                PrefCard(
                  leading: Icons.location_on,
                  title: 'Country',
                  value: countryLabel ?? '—',
                  description:
                      'Determines nearby listings and where your ads appear.',
                  onTap: () => _openPicker(
                    context,
                    title: 'Country',
                    items: localization.countries,
                    initialValue: _country,
                    onChanged: (v) {
                      setState(() {
                        _dirty = true;
                        _country = v;
                      });
                    },
                  ),
                ),

                /// Currency
                PrefCard(
                  leading: Icons.attach_money,
                  title: 'Currency',
                  value: currencyLabel ?? '—',
                  description:
                      'Used for prices when viewing and posting listings.',
                  onTap: () => _openPicker(
                    context,
                    title: 'Currency',
                    items: localization.currencies,
                    initialValue: _currency,
                    onChanged: (v) {
                      setState(() {
                        _dirty = true;
                        _currency = v;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Update',
                  onPressed: _saving ? null : _onSavePressed,
                  loading: _saving,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openPicker(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> items,
    required String? initialValue,
    required ValueChanged<String> onChanged,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalePickerPage(
          title: title,
          items: items,
          initialValue: initialValue,
          onChanged: onChanged,
        ),
      ),
    );
  }

  String? _labelFor(List<Map<String, dynamic>> items, String? code) {
    if (code == null) return null;

    final match = items.firstWhere((e) => e['code'] == code, orElse: () => {});

    return match.isNotEmpty ? match['name'] : null;
  }

  Future<void> _onSavePressed() async {
    if (_country == null || _language == null || _currency == null) {
      ShowSnack(
        context,
        'Please select country, language and currency.',
      ).error();
      return;
    }

    setState(() => _saving = true);

    final ctrl = ref.read(userPreferenceControllerProvider.notifier);

    final newState = UserPreferenceState(
      country: _country!,
      language: _language!,
      currency: _currency!,
    );

    try {
      await ctrl.updatePreference(newState, (json) async {
        // call backend update here
      });

      if (!mounted) return;

      setState(() {
        _dirty = false;
      });

      ShowSnack(context, 'Preferences updated.').success();
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Failed to update preferences.').error();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
