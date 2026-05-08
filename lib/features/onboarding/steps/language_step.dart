import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/shared/components/locale_picker_page.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';
import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/onboarding/widgets/onboarding_network_state.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';

class LanguageStep extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  const LanguageStep({super.key, this.onContinue, this.onSkip});

  @override
  ConsumerState<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends ConsumerState<LanguageStep> {
  String? selectedLanguageCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingControllerProvider.notifier)
          .initializeDefaultsIfNeeded();
    });

    final onboarding = ref.read(onboardingControllerProvider);
    selectedLanguageCode = onboarding.languageCode;

    selectedLanguageCode ??= ref
        .read(userPreferenceControllerProvider)
        .languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final localization = ref.watch(localizationControllerProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);
    final onboarding = ref.watch(onboardingControllerProvider);

    final isSaving = prefs.isSaving;

    if (localization.isLoading) {
      return OnboardingNetworkState(
        icon: Icons.cloud_sync,
        title: "Loading options",
        message:
            "We’re loading your setup options. You can retry or skip for now.",
        primaryText: "Try again",
        onPrimary: () {
          ref.read(localizationControllerProvider.notifier).load();
        },
        secondaryText: "Skip for now",
        onSecondary: widget.onSkip,
      );
    }

    if (localization.error != null) {
      return OnboardingNetworkState(
        icon: Icons.wifi_off,
        title: "No internet connection",
        message:
            "We couldn’t load these options. You can retry or continue with default settings.",
        primaryText: "Try again",
        onPrimary: () {
          ref.read(localizationControllerProvider.notifier).load();
        },
        secondaryText: "Skip for now",
        onSecondary: widget.onSkip,
      );
    }

    final languages = localization.languages;

    bool isValid(String? code) {
      if (code == null) return false;
      return languages.any((l) => (l["code"] ?? "") == code);
    }

    /// Sync with onboarding defaults (safe)
    if (selectedLanguageCode == null && isValid(onboarding.languageCode)) {
      selectedLanguageCode = onboarding.languageCode;
    }

    /// Safe fallback
    if (!isValid(selectedLanguageCode) && languages.isNotEmpty) {
      selectedLanguageCode = languages.first["code"] as String?;
    }

    String? selectedName() {
      final code = selectedLanguageCode;
      if (code == null) return null;

      try {
        final match = languages.firstWhere((l) => (l["code"] ?? "") == code);
        return match["name"]?.toString();
      } catch (_) {
        return null;
      }
    }

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    Center(
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: scheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.language,
                          size: 64,
                          color: scheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text("Choose Your Language", style: context.h4),

                    const SizedBox(height: 8),

                    Text(
                      "The app will display in your selected language",
                      style: context.pMuted,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    PickerField(
                      value: selectedName(),
                      placeholder: languages.isEmpty
                          ? "No languages available"
                          : "Select your language",
                      leading: const Icon(Icons.language),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: languages.isEmpty
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LocalePickerPage(
                                    title: "Select Language",
                                    items: languages,
                                    initialValue: selectedLanguageCode,
                                    onChanged: (code) {
                                      setState(() {
                                        selectedLanguageCode = code;
                                      });

                                      ref
                                          .read(
                                            onboardingControllerProvider
                                                .notifier,
                                          )
                                          .setLanguageCode(code);
                                    },
                                  ),
                                ),
                              );
                            },
                    ),

                    const Spacer(),

                    PrimaryButton(
                      text: "Continue",
                      loading: isSaving,
                      onPressed: isSaving
                          ? null
                          : () async {
                              final code = selectedLanguageCode ?? 'en';

                              await ref
                                  .read(
                                    userPreferenceControllerProvider.notifier,
                                  )
                                  .updateLanguageCode(code);

                              ref
                                  .read(onboardingControllerProvider.notifier)
                                  .setLanguageCode(code);

                              widget.onContinue?.call();
                            },
                    ),
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text("Skip for now", style: context.p),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
