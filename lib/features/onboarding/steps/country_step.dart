import 'dart:async';

import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_convenience_action.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_network_state.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_selection_layout.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryStep extends ConsumerWidget {
  const CountryStep({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.showBack = false,
    this.onBack,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localization = ref.watch(localizationControllerProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final preferences = ref.watch(userPreferenceControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    if (localization.isLoading ||
        (localization.error == null && !onboarding.didInitialize)) {
      return OnboardingNetworkState(
        icon: Icons.cloud_sync,
        title: l10n.onboarding_loading_title,
        message: l10n.onboarding_loading_message,
        primaryText: l10n.common_try_again,
        onPrimary: () =>
            unawaited(ref.read(localizationControllerProvider.notifier).load()),
        secondaryText: l10n.common_skip_for_now,
        onSecondary: onSkip,
        showBack: showBack,
        onBack: onBack,
      );
    }

    if (localization.error != null) {
      return OnboardingNetworkState(
        icon: Icons.wifi_off,
        title: l10n.onboarding_offline_title,
        message: l10n.onboarding_offline_message,
        primaryText: l10n.common_try_again,
        onPrimary: () =>
            unawaited(ref.read(localizationControllerProvider.notifier).load()),
        secondaryText: l10n.common_skip_for_now,
        onSecondary: onSkip,
        showBack: showBack,
        onBack: onBack,
      );
    }

    final countries = localization.countries;
    final selected = onboarding.country;
    final original = onboarding.initialResolvedCountry;
    final canRestore =
        original != null &&
        selected != null &&
        original.canonicalId != selected.canonicalId &&
        !preferences.isSaving;

    return OnboardingSelectionLayout(
      icon: Icons.location_on_rounded,
      title: l10n.onboarding_country_title,
      subtitle: l10n.onboarding_country_subtitle,
      showBack: showBack,
      onBack: onBack,
      field: PickerField(
        value: selected?.displayName,
        placeholder: countries.isEmpty
            ? l10n.common_no_countries
            : l10n.onboarding_country_placeholder,
        leading: _FlagOrIcon(
          flag: selected?.effectiveFlag,
          fallback: Icons.public_rounded,
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: countries.isEmpty
            ? null
            : () => unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LocalePickerPage<CountryOption>(
                      title: l10n.onboarding_country_picker,
                      items: countries,
                      initialId: selected?.canonicalId,
                      onChanged: controller.selectCountry,
                    ),
                  ),
                ),
              ),
      ),
      convenienceAction: OnboardingConvenienceAction(
        icon: Icons.my_location_rounded,
        label: l10n.onboarding_use_current_location,
        onPressed: canRestore
            ? () => unawaited(controller.useCurrentLocation())
            : null,
      ),
      primaryText: l10n.common_continue,
      onPrimary: selected == null || preferences.isSaving ? null : onContinue,
      secondaryText: l10n.common_skip_for_now,
      onSecondary: onSkip,
      primaryLoading: preferences.isSaving,
      error: onboarding.error == null ? null : l10n.onboarding_preference_error,
    );
  }
}

class _FlagOrIcon extends StatelessWidget {
  const _FlagOrIcon({required this.flag, required this.fallback});

  final String? flag;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    final value = flag?.trim();
    if (value == null || value.isEmpty) return Icon(fallback);
    return ExcludeSemantics(
      child: Text(value, style: const TextStyle(fontSize: 23)),
    );
  }
}
