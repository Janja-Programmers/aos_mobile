import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/localization_provider.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/ui/widgets/locale_picker_page.dart';
import 'package:africaonlinestores/features/account/shared/providers/user_preference_provider.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';

class CurrencyStep extends ConsumerStatefulWidget {
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
  ConsumerState<CurrencyStep> createState() => _CurrencyStepState();
}

class _CurrencyStepState extends ConsumerState<CurrencyStep> {
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferenceControllerProvider).value;
    selectedCurrency = prefs?.currency;
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
        final rawCurrencies = localization.currencies;

        // Normalize to what LocalePickerPage expects: {code, name}
        final currencies = rawCurrencies.map((c) {
          final code = (c["code"] ?? "").toString().toUpperCase();
          final symbol = (c["symbol"] ?? "").toString().trim();

          final display = symbol.isEmpty ? code : "$code ($symbol)";

          return <String, dynamic>{
            "code": code,
            "name": display, // used by picker
            "symbol": symbol,
          };
        }).toList();

        bool isValid(String? code) =>
            code != null && currencies.any((c) => c["code"] == code);

        // Ensure we always have a valid selection if possible
        if (!isValid(selectedCurrency)) {
          if (isValid(localization.systemDefaultCurrency)) {
            selectedCurrency = localization.systemDefaultCurrency;
          } else {
            selectedCurrency = currencies.isNotEmpty
                ? (currencies.first["code"] as String?)
                : null;
          }
        }

        Map<String, dynamic>? selectedItem() {
          if (selectedCurrency == null || currencies.isEmpty) return null;
          return currencies.firstWhere(
            (c) => c["code"] == selectedCurrency,
            orElse: () => currencies.first,
          );
        }

        final selected = selectedItem();
        final selectedDisplay = selected?["name"] as String?;
        final selectedCode = (selected?["code"] as String?)?.toUpperCase();

        return Container(
          color: scheme.surface,
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        if (widget.showBack)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: widget.onBack,
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

                        Text("Choose Your Currency", style: context.h4),
                        const SizedBox(height: 8),
                        Text(
                          "Prices will be shown in your selected currency",
                          style: context.pMuted,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        PickerField(
                          value: selectedDisplay ?? selectedCode,
                          placeholder: currencies.isEmpty
                              ? "No currencies available"
                              : "Select your currency",
                          leading: const Icon(Icons.currency_exchange),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: currencies.isEmpty
                              ? null
                              : () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LocalePickerPage(
                                        title: "Select Currency",
                                        items: currencies,
                                        initialValue: selectedCurrency,
                                        onChanged: (code) {
                                          setState(
                                            () => selectedCurrency = code,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                        ),

                        const Spacer(),

                        PrimaryButton(
                          text: "Get Started",
                          loading: isSaving,
                          onPressed:
                              selectedCurrency == null ||
                                  isSaving ||
                                  currencies.isEmpty
                              ? null
                              : () async {
                                  await ref
                                      .read(
                                        userPreferenceControllerProvider
                                            .notifier,
                                      )
                                      .updateCurrency(selectedCurrency!);

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
