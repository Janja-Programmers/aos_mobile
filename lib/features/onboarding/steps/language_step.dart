import 'dart:async';

import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/localization/models/localization_models.dart';
import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_network_state.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_selection_layout.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageStep extends ConsumerWidget {
  const LanguageStep({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

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
      );
    }

    final languages = localization.languages;
    final selected = onboarding.language;

    return OnboardingSelectionLayout(
      icon: Icons.language_rounded,
      title: l10n.onboarding_language_title,
      subtitle: l10n.onboarding_language_subtitle,
      field: PickerField(
        value: selected?.displayName,
        placeholder: languages.isEmpty
            ? l10n.common_no_languages
            : l10n.onboarding_language_placeholder,
        leading: _FlagOrIcon(
          flag: selected?.effectiveFlag,
          fallback: Icons.language_rounded,
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: languages.isEmpty
            ? null
            : () => unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LocalePickerPage<LanguageOption>(
                      title: l10n.onboarding_language_picker,
                      items: languages,
                      initialId: selected?.canonicalId,
                      onChanged: controller.selectLanguage,
                    ),
                  ),
                ),
              ),
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
