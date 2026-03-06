import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/localization/localization_controller.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class LanguageStep extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  const LanguageStep({super.key, this.onContinue, this.onSkip});

  @override
  ConsumerState<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends ConsumerState<LanguageStep> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingControllerProvider.notifier)
          .initializeDefaultsIfNeeded();
    });

    // Prefer onboarding state's auto-detected default.
    final onboarding = ref.read(onboardingControllerProvider);
    selectedLanguage = onboarding.language;

    // If onboarding didn't set it yet, fall back to saved preference.
    selectedLanguage ??= ref.read(userPreferenceControllerProvider).language;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final localization = ref.watch(localizationControllerProvider);
    final prefs = ref.watch(userPreferenceControllerProvider);
    final onboarding = ref.watch(onboardingControllerProvider);

    final isSaving = prefs.isSaving;

    // Sync localization state handling
    if (localization.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (localization.error != null) {
      return const SizedBox.shrink();
    }

    final languages = localization.languages;

    bool isValid(String? code) =>
        code != null && languages.any((l) => l["code"] == code);

    // Auto-fill once from onboarding controller (detected + validated there),
    // but only if the user hasn't picked locally yet.
    if (selectedLanguage == null && isValid(onboarding.language)) {
      selectedLanguage = onboarding.language;
    }

    // If still not valid, pick a safe default from the list (once).
    if (!isValid(selectedLanguage)) {
      selectedLanguage = languages.isNotEmpty
          ? (languages.first["code"] as String?)
          : null;
    }

    String? selectedName() {
      final code = selectedLanguage;
      if (code == null) return null;

      final match = languages.firstWhere(
        (l) => l["code"] == code,
        orElse: () => {},
      );

      return match.isNotEmpty ? match["name"] as String? : null;
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
                                    initialValue: selectedLanguage,
                                    onChanged: (code) {
                                      setState(() => selectedLanguage = code);
                                      ref
                                          .read(
                                            onboardingControllerProvider
                                                .notifier,
                                          )
                                          .setLanguage(code);
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
                      onPressed:
                          selectedLanguage == null ||
                              isSaving ||
                              languages.isEmpty
                          ? null
                          : () async {
                              // Persist selection globally.
                              await ref
                                  .read(
                                    userPreferenceControllerProvider.notifier,
                                  )
                                  .updateLanguage(selectedLanguage!);

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
