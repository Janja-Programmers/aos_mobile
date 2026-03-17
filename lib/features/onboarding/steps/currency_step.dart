import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/onboarding/controller/onboarding_controller.dart';
import 'package:africaonlinestores/features/localization/controller/localization_controller.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';

import 'package:africaonlinestores/l10n/gen/app_localizations.dart';

class CurrencyStep extends ConsumerWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;
  final bool showBack;
  final VoidCallback? onBack;

  const CurrencyStep({
    super.key,
    this.onContinue,
    this.onSkip,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final localization = ref.watch(localizationControllerProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    if (localization.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (localization.error != null) {
      return Center(child: Text("Failed to load currencies", style: context.p));
    }

    final currencies = localization.currencies;
    final selectedCurrencyCode = onboarding.currencyCode;

    Map<String, dynamic>? selectedItem() {
      if (currencies.isEmpty) return null;

      final code = (selectedCurrencyCode ?? "USD").toUpperCase();

      try {
        return currencies.firstWhere(
          (c) => (c["code"] ?? "").toString().toUpperCase() == code,
        );
      } catch (_) {
        return currencies.first;
      }
    }

    final selected = selectedItem();

    final currencyLabel = (selected?["display"] ?? selected?["code"])
        ?.toString();

    final currencyCode = (selected?["code"] ?? selectedCurrencyCode)
        ?.toString();

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
                    const SizedBox(height: 12),

                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                    const SizedBox(height: 8),

                    Center(
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: scheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.currency_exchange,
                          size: 64,
                          color: scheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(l10n.onboarding_currency_title, style: context.h4),

                    const SizedBox(height: 8),

                    Text(
                      l10n.onboarding_currency_subtitle,
                      style: context.pMuted,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    PickerField(
                      value: currencyLabel,
                      placeholder: currencies.isEmpty
                          ? l10n.common_no_currencies
                          : l10n.onboarding_currency_placeholder,
                      leading: const Icon(Icons.currency_exchange),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: currencies.isEmpty
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LocalePickerPage(
                                    title: l10n.onboarding_currency_picker,
                                    items: currencies,
                                    initialValue: selectedCurrencyCode,
                                    onChanged: (code) {
                                      controller.setCurrencyCode(code);
                                    },
                                  ),
                                ),
                              );
                            },
                    ),

                    const Spacer(),

                    PrimaryButton(
                      text: l10n.common_get_started,
                      onPressed: currencies.isEmpty
                          ? null
                          : () {
                              if (currencyCode != null) {
                                controller.setCurrencyCode(currencyCode);
                              }

                              controller.nextStep();
                              onContinue?.call();
                            },
                    ),

                    TextButton(
                      onPressed: onSkip,
                      child: Text(l10n.common_skip_for_now),
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
