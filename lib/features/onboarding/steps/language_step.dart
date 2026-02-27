import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/localization_provider.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/account/shared/providers/user_preference_provider.dart';
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
    final prefs = ref.read(userPreferenceControllerProvider).value;
    selectedLanguage = prefs?.language;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final localizationAsync = ref.watch(localizationControllerProvider);
    final prefsAsync = ref.watch(userPreferenceControllerProvider);
    final isSaving = prefsAsync.isLoading;

    return localizationAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (localization) {
        final languages = localization.languages;

        selectedLanguage ??= localization.systemDefaultLanguage;

        String? selectedName() {
          if (selectedLanguage == null) return null;
          final match = languages.firstWhere(
            (l) => l["code"] == selectedLanguage,
            orElse: () => languages.first,
          );
          return match["name"] as String?;
        }

        return Container(
          color: scheme.surface,
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // helps when keyboard shows up too
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),

                        Center(
                          child: CircleAvatar(
                            radius: 56, // slightly smaller to help tiny screens
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
                          placeholder: "Select your language",
                          leading: const Icon(Icons.language),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LocalePickerPage(
                                  title: "Select Language",
                                  items: languages,
                                  initialValue: selectedLanguage,
                                  onChanged: (code) {
                                    setState(() => selectedLanguage = code);
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
                          onPressed: selectedLanguage == null || isSaving
                              ? null
                              : () async {
                                  await ref
                                      .read(
                                        userPreferenceControllerProvider
                                            .notifier,
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
      },
    );
  }
}
