import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/presentation/widgets/pref_card.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
import 'package:africaonlinestores/shared/utils/flag_emoji.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class PreferenceScreen extends ConsumerStatefulWidget {
  const PreferenceScreen({super.key});

  @override
  ConsumerState<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends ConsumerState<PreferenceScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    final localization = ref.watch(localizationControllerProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);

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

    final countryLabel = _labelFor(localization.countries, prefs.countryCode);
    final languageLabel = _labelFor(localization.languages, prefs.languageCode);
    final currencyLabel = _labelFor(
      localization.currencies,
      prefs.currencyCode,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: colors.textPrimary,
        ),
        title: Text(l10n.settings_preferences, style: context.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings_manage_app, style: context.pMuted),
            const SizedBox(height: 24),

            /// Language
            PrefCard(
              leading: Icons.translate,
              title: l10n.settings_language,
              value: languageLabel ?? '—',
              description: l10n.settings_language_description,
              onTap: () => _openPicker(
                context,
                title: l10n.settings_language,
                items: localization.languages,
                initialValue: prefs.languageCode,
                type: _PreferenceType.language,
              ),
            ),

            /// Country
            PrefCard(
              leading: Icons.location_on_outlined,
              title: l10n.settings_country,
              value: countryLabel ?? '—',
              description: l10n.settings_country_description,
              onTap: () => _openPicker(
                context,
                title: l10n.settings_country,
                items: localization.countries,
                initialValue: prefs.countryCode,
                type: _PreferenceType.country,
              ),
            ),

            /// Currency
            PrefCard(
              leading: Icons.attach_money,
              title: l10n.settings_currency,
              value: currencyLabel ?? '—',
              description: l10n.settings_currency_description,
              onTap: () => _openPicker(
                context,
                title: l10n.settings_currency,
                items: localization.currencies,
                initialValue: prefs.currencyCode,
                type: _PreferenceType.currency,
              ),
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
    required _PreferenceType type,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalePickerPage(
          title: 'Select $title',
          items: items,
          initialValue: initialValue,
          leadingBuilder: (it) => Text(
            flagEmoji((it['code'] ?? '').toString().toUpperCase()),
            style: const TextStyle(fontSize: 24),
          ),
          onChanged: (_) {},
          onSave: (value) => _savePreference(type, value),
          saveButtonText: 'Save',
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

  Future<void> _savePreference(_PreferenceType type, String value) async {
    final clean = value.trim();
    if (clean.isEmpty) return;

    final ctrl = ref.read(userPreferenceControllerProvider.notifier);
    final current = ref.read(userPreferenceControllerProvider);

    try {
      switch (type) {
        case _PreferenceType.language:
          await ctrl.updatePreferences(
            countryCode: current.countryCode,
            languageCode: clean,
            currencyCode: current.currencyCode,
          );
          await _syncServer({'language': clean});
          break;
        case _PreferenceType.country:
          await ctrl.updatePreferences(
            countryCode: clean,
            languageCode: current.languageCode,
            currencyCode: current.currencyCode,
          );
          await _syncServer({'country': clean});
          break;
        case _PreferenceType.currency:
          await ctrl.updatePreferences(
            countryCode: current.countryCode,
            languageCode: current.languageCode,
            currencyCode: clean,
          );
          await _syncServer({'currency': clean});
          break;
      }

      if (!mounted) return;
      ShowSnack(context, 'Preference updated.').success();
    } catch (_) {
      if (!mounted) return;
      ShowSnack(context, 'Failed to update preference.').error();
      rethrow;
    }
  }

  Future<void> _syncServer(Map<String, dynamic> payload) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) return;

    final api = ref.read(userPreferenceApiProvider);
    final res = await api.updateMyPreferences(payload);
    if (res.isLeft) throw Exception(res.leftOrNull?.message);
  }
}

enum _PreferenceType { language, country, currency }
