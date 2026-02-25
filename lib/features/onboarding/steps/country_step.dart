import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class CountryStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final bool showBack;
  final VoidCallback? onBack;

  const CountryStep({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.showBack = false,
    this.onBack,
  });

  @override
  ConsumerState<CountryStep> createState() => _CountryStepState();
}

class _CountryStepState extends ConsumerState<CountryStep> {
  String? selectedCountry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final localizationAsync = ref.watch(localizationControllerProvider);
    final prefsAsync = ref.watch(userPreferenceControllerProvider);
    final isSaving = prefsAsync.isLoading;

    return localizationAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (localization) {
        final countries = localization.countries;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.showBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                ),

              const SizedBox(height: 20),

              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: colors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.location_on,
                    size: 80,
                    color: colors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text("Set Your Country", style: context.h4),
              const SizedBox(height: 8),
              Text(
                "We'll show you products and sellers near you",
                style: context.pMuted,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              PickerField(
                value: selectedCountry == null
                    ? null
                    : countries.firstWhere(
                        (l) => l["code"] == selectedCountry,
                        orElse: () => countries.first,
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
                              Text("Select Country", style: context.h5),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: countries.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox.shrink(),
                                  itemBuilder: (_, i) {
                                    final l = countries[i];

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
                    setState(() => selectedCountry = result);
                  }
                },
              ),

              const Spacer(),

              PrimaryButton(
                text: "Get Started",
                loading: isSaving,
                onPressed: selectedCountry == null || isSaving
                    ? null
                    : () async {
                        await ref
                            .read(userPreferenceControllerProvider.notifier)
                            .updateCountry(selectedCountry!);

                        widget.onContinue();
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
