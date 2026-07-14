import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/pref_card.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
import 'package:africaonlinestores/shared/utils/flag_emoji.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final auth = ref.watch(authControllerProvider);
    final isSeller = auth.asAuthenticated?.seller.isSeller ?? false;

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
              description: isSeller
                  ? 'Seller country is locked to protect your marketplace data.'
                  : l10n.settings_country_description,
              enabled: !isSeller,
              readOnlyLabel: isSeller ? 'Locked' : null,
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
              description: isSeller
                  ? 'Seller currency is locked to keep listings consistent.'
                  : l10n.settings_currency_description,
              enabled: !isSeller,
              readOnlyLabel: isSeller ? 'Locked' : null,
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
      MaterialPageRoute<void>(
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
        ),
      ),
    );
  }

  String? _labelFor(List<Map<String, dynamic>> items, String? code) {
    if (code == null) return null;

    try {
      final clean = code.trim();
      final upper = clean.toUpperCase();
      final lower = clean.toLowerCase();
      final match = items.firstWhere((e) {
        final itemCode = (e['code'] ?? '').toString();
        final itemName = (e['name'] ?? '').toString();
        final itemDisplay = (e['display'] ?? '').toString();

        return itemCode.toUpperCase() == upper ||
            itemName.toLowerCase() == lower ||
            itemDisplay.toLowerCase() == lower;
      });

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
    final localization = ref.read(localizationControllerProvider);

    final auth = ref.read(authControllerProvider);
    final isSeller = auth.asAuthenticated?.seller.isSeller ?? false;

    if (isSeller && type != _PreferenceType.language) {
      if (!mounted) return;
      ShowSnack(
        context,
        'Country and currency are locked for seller accounts.',
      ).error();
      return;
    }

    final countryCode = type == _PreferenceType.country
        ? UserPreferenceState.normalizeCountryCode(clean)
        : _canonicalPreferenceValue(
            localization.countries,
            current.countryCode,
            preferName: true,
          );
    final languageCode = type == _PreferenceType.language
        ? UserPreferenceState.normalizeLanguageCode(clean)
        : current.languageCode;
    final currencyCode = type == _PreferenceType.currency
        ? UserPreferenceState.normalizeCurrencyCode(clean)
        : _canonicalPreferenceValue(
            localization.currencies,
            current.currencyCode,
            preferName: false,
          );

    try {
      final serverPrefs = await _syncServer(
        countryCode: countryCode,
        languageCode: languageCode,
        currencyCode: currencyCode,
      );

      final resolvedCountry = _preferenceValue(
        serverPrefs['country'],
        fallback: countryCode,
      );
      final resolvedLanguage = _preferenceValue(
        serverPrefs['language'],
        fallback: languageCode,
      );
      final resolvedCurrency = _preferenceValue(
        serverPrefs['currency'],
        fallback: currencyCode,
      );

      await ctrl.updatePreferences(
        countryCode: resolvedCountry,
        languageCode: resolvedLanguage,
        currencyCode: resolvedCurrency,
      );

      ref.read(authControllerProvider.notifier).setPreferencesFromMap({
        'country': resolvedCountry,
        'language': resolvedLanguage,
        'currency': resolvedCurrency,
      });

      if (!mounted) return;
      ShowSnack(context, 'Preference updated.').success();
    } catch (err) {
      if (!mounted) return;
      final message = err.toString().replaceFirst('Exception: ', '').trim();
      ShowSnack(
        context,
        message.isEmpty ? 'Failed to update preference.' : message,
      ).error();
      rethrow;
    }
  }

  String _canonicalPreferenceValue(
    List<Map<String, dynamic>> items,
    String value, {
    required bool preferName,
  }) {
    final clean = value.trim();
    if (clean.isEmpty) return clean;

    final upper = clean.toUpperCase();
    final lower = clean.toLowerCase();

    try {
      final match = items.firstWhere((e) {
        final itemCode = (e['code'] ?? '').toString();
        final itemName = (e['name'] ?? '').toString();
        final itemDisplay = (e['display'] ?? '').toString();

        return itemCode.toUpperCase() == upper ||
            itemName.toLowerCase() == lower ||
            itemDisplay.toLowerCase() == lower;
      });

      final raw = preferName
          ? (match['name'] ?? match['code'] ?? match['display'])
          : (match['code'] ?? match['name'] ?? match['display']);
      final resolved = asString(raw).trim();
      return resolved.isEmpty ? clean : resolved;
    } catch (_) {
      return clean;
    }
  }

  Future<Map<String, dynamic>> _syncServer({
    required String countryCode,
    required String languageCode,
    required String currencyCode,
  }) async {
    final payload = <String, dynamic>{
      'country': countryCode,
      'language': languageCode,
      'currency': currencyCode,
    };

    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) return payload;

    final api = ref.read(userPreferenceApiProvider);
    final res = await api.updateMyPreferences(payload);
    if (res.isLeft) {
      throw Exception(
        res.leftOrNull?.message ?? 'Failed to update preference.',
      );
    }

    final data = res.rightOrNull ?? const <String, dynamic>{};
    return data.isEmpty ? payload : data;
  }

  String _preferenceValue(Object? raw, {required String fallback}) {
    if (raw is Map) {
      final map = asJsonMap(raw);
      final code = asString(map['code']).trim();
      if (code.isNotEmpty) return code;
      final name = asString(map['name']).trim();
      if (name.isNotEmpty) return name;
      final id = asString(map['id']).trim();
      if (id.isNotEmpty) return id;
    }

    final value = asString(raw).trim();
    return value.isEmpty ? fallback : value;
  }
}

enum _PreferenceType { language, country, currency }
