import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/account/ui/widgets/pref_card.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/shared/utils/flag_emoji.dart';

class PreferenceScreen extends ConsumerStatefulWidget {
  const PreferenceScreen({super.key});

  @override
  ConsumerState<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  String? _country;
  String? _language;
  String? _currency;

  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final localization = ref.watch(localizationControllerProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);

    if (!_dirty) {
      _country ??= prefs.countryCode;
      _language ??= prefs.languageCode;
      _currency ??= prefs.currencyCode;
    }

    final isSaving = prefs.isSaving;

    if (localization.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (localization.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load locale options.',
            style: TextStyle(color: colors.textPrimary),
          ),
        ),
      );
    }

    final countryLabel = _labelFor(localization.countries, _country);
    final languageLabel = _labelFor(localization.languages, _language);
    final currencyLabel = _labelFor(localization.currencies, _currency);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage how the app works for you', style: context.p),
            const SizedBox(height: 16),

            /// Language
            PrefCard(
              leading: Icons.translate,
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
              leading: Icons.location_on_outlined,
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
              description: 'Used for prices when viewing and posting listings.',
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
              loading: isSaving,
              onPressed: isSaving ? null : _onSavePressed,
            ),
          ],
        ),
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
          leadingBuilder: (it) => Text(
            flagEmoji((it["code"] ?? "").toString().toUpperCase()),
            style: const TextStyle(fontSize: 22),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String? _labelFor(List<Map<String, dynamic>> items, String? code) {
    if (code == null) return null;

    try {
      final match = items.firstWhere(
        (e) => (e['code'] ?? '').toString().toUpperCase() == code.toUpperCase(),
      );

      return (match['name'] ?? match['display'] ?? code).toString();
    } catch (_) {
      return code;
    }
  }

  Future<void> _onSavePressed() async {
    if (_country == null || _language == null || _currency == null) {
      ShowSnack(
        context,
        'Please select country, language and currency.',
      ).error();
      return;
    }

    final ctrl = ref.read(userPreferenceControllerProvider.notifier);

    try {
      /// 1️⃣ Update local preferences
      await ctrl.updatePreferences(
        countryCode: _country,
        languageCode: _language,
        currencyCode: _currency,
      );

      /// 2️⃣ Update server if logged in
      final auth = ref.read(authControllerProvider);

      if (auth.isAuthenticated) {
        final api = ref.read(userPreferenceApiProvider);

        await api.updateMyPreferences({
          "country": _country,
          "language": _language,
          "currency": _currency,
        });
      }

      if (!mounted) return;

      setState(() {
        _dirty = false;
      });

      ShowSnack(context, 'Preferences updated.').success();
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Failed to update preferences.').error();
    }
  }
}
