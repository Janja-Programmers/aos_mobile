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
          Text("Business Information", style: context.h6),
          const SizedBox(height: 4),
          Text(
            "Provide accurate details about your business for verification.",
            style: context.p.copyWith(color: colors.textMuted),
          ),

          const SizedBox(height: 16),

          _InputField(
            label: "Business Name",
            initialValue: data.businessName,
            onChanged: (val) => controller.updateBasic(businessName: val),
          ),

          const SizedBox(height: 12),

          _DropdownField(
            label: "Business Type",
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
            initialValue: data.businessPhoneNumber,
            keyboardType: TextInputType.phone,
            onChanged: (val) => controller.updateBasic(phone: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Email",
            initialValue: data.businessEmail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => controller.updateBasic(email: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Website (Optional)",
            initialValue: data.businessWebsite,
            onChanged: (val) => controller.updateBasic(website: val),
          ),

          const SizedBox(height: 12),

          _InputField(
            label: "Physical Address",
            initialValue: data.physicalAddress,
            maxLines: 2,
            onChanged: (val) => controller.updateBasic(address: val),
          ),

          const SizedBox(height: 20),

          // --- Bottom Info Card (Aligned with design system) ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ensure your details match official documents. Incorrect information may delay verification.",
                    style: context.p.copyWith(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
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
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String? initialValue;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
  });

  final String label;
  final List<String> items;
  final String? value;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
