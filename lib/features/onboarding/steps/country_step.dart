import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/utils/flag_emoji.dart';

class CountryStep extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;

    final localization = ref.watch(localizationControllerProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final countries = localization.countries;
    final selectedCountryCode = onboarding.countryCode;

    Map<String, dynamic>? selectedItem() {
      if (selectedCountryCode == null || countries.isEmpty) return null;

      try {
        return countries.firstWhere(
          (c) =>
              (c["code"] ?? "").toString().toUpperCase() ==
              selectedCountryCode.toUpperCase(),
        );
      } catch (_) {
        return null;
      }
    }

    final selected = selectedItem();
    final selectedName = selected?["name"] as String?;
    final selectedCode = (selected?["code"] as String?)?.toUpperCase();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: onBack,
                        ),
                      ),

                    const SizedBox(height: 16),

                    Center(
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: colors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.location_on,
                          size: 64,
                          color: colors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(l10n.onboarding_country_title, style: context.h4),

                    const SizedBox(height: 8),

                    Text(
                      l10n.onboarding_country_subtitle,
                      style: context.pMuted,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    PickerField(
                      value: selectedName,
                      placeholder: l10n.onboarding_country_title,
                      leading: selectedCode == null
                          ? const Icon(Icons.public)
                          : Text(
                              flagEmoji(selectedCode),
                              style: const TextStyle(fontSize: 22),
                            ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: countries.isEmpty
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LocalePickerPage(
                                    title: l10n.onboarding_country_picker,
                                    items: countries,
                                    initialValue: selectedCountryCode,
                                    leadingBuilder: (it) => Text(
                                      flagEmoji(
                                        (it["code"] as String).toUpperCase(),
                                      ),
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    onChanged: (code) {
                                      controller.setCountryCode(code);
                                    },
                                  ),
                                ),
                              );
                            },
                    ),

                    const Spacer(),

                    PrimaryButton(
                      text: l10n.common_continue,
                      onPressed: selectedCountryCode == null
                          ? null
                          : () {
                              controller.nextStep();
                              onContinue();
                            },
                    ),

                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        l10n.common_skip_for_now,
                        style: context.pMuted,
                      ),
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
