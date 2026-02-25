import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
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

        // Prepopulate if empty
        selectedLanguage ??= localization.systemDefaultLanguage;

        return Container(
          color: scheme.surface,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 🔴 Icon doubled in size (40 → 80)
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: scheme.primary.withOpacity(0.1),
                  child: Icon(Icons.language, size: 80, color: scheme.primary),
                ),
              ),

              const SizedBox(height: 40),

              Text("Choose Your Language", style: context.h4),
              const SizedBox(height: 8),
              Text(
                "The app will display in your selected language",
                style: context.pMuted,
              ),

              const SizedBox(height: 24),

              PickerField(
                value: selectedLanguage == null
                    ? null
                    : languages.firstWhere(
                        (l) => l["code"] == selectedLanguage,
                        orElse: () => languages.first,
                      )["name"],
                placeholder: "Select your language",
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text("Select Language", style: context.h5),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: languages.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox.shrink(),
                                  itemBuilder: (_, i) {
                                    final l = languages[i];

                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              l["name"],
                                              style: context.p,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l["code"].toUpperCase(),
                                            style: context.pMuted,
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(context, l["code"]);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (result != null) {
                    setState(() => selectedLanguage = result);
                  }
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
                            .read(userPreferenceControllerProvider.notifier)
                            .updateLanguage(selectedLanguage!);

                        widget.onContinue?.call();
                      },
              ),
              TextButton(
                onPressed: widget.onSkip,
                child: Text("Skip for now", style: context.p),
              ),
            ],
          ),
        );
      },
    );
  }
}
