import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/pref_card.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/data/preferences_api_provider.dart';
import 'package:africaonlinestores/features/preferences/models/active_preference_snapshot.dart';
import 'package:africaonlinestores/features/preferences/models/preference_access_policy.dart';
import 'package:africaonlinestores/features/preferences/models/user_preference_field.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
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
    final preferences = ref.watch(userPreferenceControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final countryLocked = !PreferenceAccessPolicy.canEdit(
      UserPreferenceField.country,
      auth,
    );
    final snapshot = preferences.snapshot;

    if (localization.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (localization.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              localization.error!,
              style: TextStyle(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
          children: <Widget>[
            Text(l10n.settings_manage_app, style: context.pMuted),
            const SizedBox(height: 24),
            PrefCard(
              leading: Icons.translate,
              title: l10n.settings_language,
              value: snapshot?.language.displayName ?? '—',
              description: l10n.settings_language_description,
              onTap: () => _openPicker<LanguageOption>(
                title: l10n.settings_language,
                items: localization.languages,
                initialId: snapshot?.language.canonicalId,
                type: _PreferenceType.language,
              ),
            ),
            PrefCard(
              leading: Icons.location_on_outlined,
              title: l10n.settings_country,
              value: snapshot?.country.displayName ?? '—',
              description: countryLocked
                  ? l10n.settings_seller_country_locked_description
                  : l10n.settings_country_description,
              enabled: !countryLocked,
              readOnlyLabel: countryLocked ? l10n.common_locked : null,
              onTap: () => _openPicker<CountryOption>(
                title: l10n.settings_country,
                items: localization.countries,
                initialId: snapshot?.country.canonicalId,
                type: _PreferenceType.country,
              ),
            ),
            PrefCard(
              leading: Icons.attach_money,
              title: l10n.settings_currency,
              value: snapshot?.currency.displayName ?? '—',
              description: l10n.settings_currency_description,
              onTap: () => _openPicker<CurrencyOption>(
                title: l10n.settings_currency,
                items: localization.currencies,
                initialId: snapshot?.currency.canonicalId,
                type: _PreferenceType.currency,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker<T extends LocaleOption>({
    required String title,
    required List<T> items,
    required String? initialId,
    required _PreferenceType type,
  }) {
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LocalePickerPage<T>(
            title: title,
            items: items,
            initialId: initialId,
            onChanged: (_) => Future<void>.value(),
            onSave: (item) => _savePreference(type, item),
          ),
        ),
      ),
    );
  }

  Future<void> _savePreference(
    _PreferenceType type,
    LocaleOption option,
  ) async {
    final auth = ref.read(authControllerProvider);
    final countryLocked = !PreferenceAccessPolicy.canEdit(
      UserPreferenceField.country,
      auth,
    );
    final sellerCountryLockedMessage =
        context.l10n.settings_seller_country_locked;
    final preferenceErrorMessage = context.l10n.onboarding_preference_error;
    final preferenceUpdatedMessage = context.l10n.settings_preference_updated;

    if (countryLocked && type == _PreferenceType.country) {
      ShowSnack(context, sellerCountryLockedMessage).error();
      return;
    }

    final controller = ref.read(userPreferenceControllerProvider.notifier);
    if (!auth.isAuthenticated) {
      await switch (type) {
        _PreferenceType.language => controller.updateLanguage(
          option as LanguageOption,
        ),
        _PreferenceType.country => controller.updateCountry(
          option as CountryOption,
        ),
        _PreferenceType.currency => controller.updateCurrency(
          option as CurrencyOption,
        ),
      };
      return;
    }

    final field = switch (type) {
      _PreferenceType.language => UserPreferenceField.language,
      _PreferenceType.country => UserPreferenceField.country,
      _PreferenceType.currency => UserPreferenceField.currency,
    };
    final api = ref.read(userPreferenceApiProvider);
    final result = await api.updateMyPreference(
      field: field,
      canonicalId: option.canonicalId,
    );
    if (result.isLeft) {
      final message = result.leftOrNull?.message ?? preferenceErrorMessage;
      if (mounted) ShowSnack(context, message).error();
      throw StateError(message);
    }

    final serverPreferences = result.rightOrNull ?? <String, dynamic>{};
    await controller.syncFromServerPreferences(
      serverPreferences,
      authority: PreferenceAuthority.authenticatedUpdate,
    );
    ref
        .read(authControllerProvider.notifier)
        .setPreferencesFromMap(serverPreferences);

    if (mounted) {
      ShowSnack(context, preferenceUpdatedMessage).success();
    }
  }
}

enum _PreferenceType { language, country, currency }
