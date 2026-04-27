import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';

class BasicInfoStep extends ConsumerWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerVerificationControllerProvider);
    final controller = ref.read(sellerVerificationControllerProvider.notifier);

    final data = state.data;
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(Icons.business, size: 36, color: colors.primary),
              ),
              const SizedBox(height: 16),

              Text(
                "Business Information",
                style: context.h5.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: 6),

              Text(
                "Enter your basic business details. You can add more information in your seller storefront after verification",
                style: context.p.copyWith(color: colors.textMuted),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _InputField(
            label: "Business Name *",
            icon: Icons.store_outlined,
            hintText: "Enter your business name",
            initialValue: data.businessName,
            onChanged: (val) => controller.updateBasic(businessName: val),
          ),

          const SizedBox(height: 12),

          _DropdownField(
            label: "Business Type",
            hintText: "Select Business Type",
            value: data.businessType,
            items: const [
              "Sole Proprietorship",
              "Partnership",
              "Limited Company",
              "Corporation",
            ],
            onChanged: (val) => controller.updateBasic(businessType: val),
          ),

          const SizedBox(height: 12),

          // --- Category ---
          _InputField(
            label: "What are you selling? *",
            icon: Icons.local_offer_outlined,
            hintText: "e.g. Electronics, Clothing, Food, Services...",
            initialValue: data.businessCategory,
            onChanged: (val) => controller.updateBasic(businessCategory: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Business Phone Number *",
            icon: Icons.phone_outlined,
            hintText: "+254 xxx xxx xxx",
            initialValue: data.businessPhoneNumber,
            keyboardType: TextInputType.phone,
            onChanged: (val) => controller.updateBasic(phone: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Email",
            icon: Icons.email_outlined,
            hintText: "example@gmail.com",
            initialValue: data.businessEmail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => controller.updateBasic(email: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Physical Location *",
            icon: Icons.location_on_outlined,
            hintText: "City/Town and address of business operations",
            initialValue: data.physicalAddress,
            maxLines: 2,
            onChanged: (val) => controller.updateBasic(address: val),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    this.hintText,
    this.icon,
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String? hintText;
  final IconData? icon;
  final String? initialValue;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔤 LABEL
        Text(
          label,
          style: context.p.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        /// 🧱 INPUT
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: colors.textMuted)
                : null,
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.items,
    this.value,
    this.hintText,
    this.onChanged,
  });

  final String label;
  final List<String> items;
  final String? value;
  final String? hintText;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.p.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: value,
          hint: hintText != null ? Text(hintText!) : null,
          menuMaxHeight: 300,
          isExpanded: true,

          selectedItemBuilder: (context) {
            return items.map((e) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                  style: context.p.copyWith(color: colors.textPrimary),
                ),
              );
            }).toList();
          },

          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                child: Text(
                  e,
                  style: context.p.copyWith(color: colors.textPrimary),
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}
