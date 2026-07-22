import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/presentation/steps/user_verification_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalDetailsStep extends ConsumerWidget {
  const PersonalDetailsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(userVerificationControllerProvider);
    final controller = ref.read(userVerificationControllerProvider.notifier);
    final draft = state.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserVerificationStepHeader(
            icon: Icons.person_outline_rounded,
            title: 'Personal Details',
            subtitle:
                'Enter your legal name exactly as it appears on your identity document and provide a reachable phone number.',
          ),
          const SizedBox(height: 28),
          _DetailsField(
            key: const ValueKey('user-verification-legal-name'),
            label: 'Legal Name *',
            hintText: 'Enter your full legal name',
            initialValue: draft.legalName,
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
            enabled: !state.isBusy,
            onChanged: (value) {
              controller.updatePersonalDetails(legalName: value);
            },
          ),
          const SizedBox(height: 18),
          _DetailsField(
            key: const ValueKey('user-verification-phone-number'),
            label: 'Phone Number *',
            hintText: '+254 700 000 000',
            initialValue: draft.phoneNumber,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()\-]')),
              LengthLimitingTextInputFormatter(24),
            ],
            enabled: !state.isBusy,
            onChanged: (value) {
              controller.updatePersonalDetails(phoneNumber: value);
            },
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.primary.withValues(alpha: 0.20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use a phone number you currently own and can be reached on. Include the country code.',
                    style: context.pMuted.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsField extends StatelessWidget {
  const _DetailsField({
    super.key,
    required this.label,
    required this.hintText,
    required this.initialValue,
    required this.prefixIcon,
    required this.keyboardType,
    required this.textInputAction,
    required this.autofillHints,
    required this.inputFormatters,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final String initialValue;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.pStrong.copyWith(color: colors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          textCapitalization: keyboardType == TextInputType.name
              ? TextCapitalization.words
              : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: colors.textMuted, size: 21),
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
