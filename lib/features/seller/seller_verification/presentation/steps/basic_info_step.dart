import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';

import 'package:africaonlinestores/shared/components/picker_field.dart';

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
            ],
            onChanged: (val) => controller.updateBasic(businessType: val),
          ),

          const SizedBox(height: 12),

          // --- Category ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Business Category", style: context.p),
              const SizedBox(height: 6),
              PickerField(
                value: data.businessCategory,
                leading: const Icon(Icons.category_outlined),
                placeholder: "Select a category",
                onTap: () async {
                  CategoryNode? parentNode;

                  final res = await context.pushNamed<Map<String, dynamic>>(
                    AppRoutes.nSelectCategory,
                    extra: {"initialParent": parentNode},
                  );

                  if (res == null) return;

                  final label = (res['label'] ?? '').toString();
                  if (label.isEmpty) return;

                  controller.updateBasic(businessCategory: label);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Phone Number",
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
            label: "Website (Optional)",
            icon: Icons.link,
            hintText: "https://sitename.com",
            initialValue: data.businessWebsite,
            keyboardType: TextInputType.url,
            onChanged: (val) => controller.updateBasic(website: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Physical Address",
            icon: Icons.location_on_outlined,
            hintText: "City/Town and address of business operations",
            initialValue: data.physicalAddress,
            maxLines: 2,
            onChanged: (val) => controller.updateBasic(address: val),
          ),

          const SizedBox(height: 20),

          // --- Bottom Info Card (Aligned with design system) ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.blue.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.blue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Registration number, address, email, website, tax info, and operating hours can be added in your seller storefront after verification",
                    style: context.body.copyWith(fontSize: 12.5),
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
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
