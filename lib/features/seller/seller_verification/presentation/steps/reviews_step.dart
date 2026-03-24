import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';

class ReviewStep extends ConsumerWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerVerificationControllerProvider);
    final data = state.data;
    final colors = context.appColors;

    String? getDoc(String type) {
      try {
        return data.documents
            .firstWhere((e) => e.documentType == type)
            .attachment;
      } catch (_) {
        return null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // --- Header ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Review Details", style: context.h6),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Confirm your information before submitting.",
              style: context.p.copyWith(color: colors.textMuted),
            ),
          ),

          const SizedBox(height: 16),

          // --- Business Info Card ---
          _sectionCard(
            context,
            title: "Business Information",
            children: [
              _row("Business Name", data.businessName),
              _row("Business Type", data.businessType),
              _row("Category", data.businessCategory),
              _row("Phone", data.businessPhoneNumber),
              _row("Email", data.businessEmail),
              _row("Website", data.businessWebsite),
              _row("Address", data.physicalAddress),
            ],
          ),

          const SizedBox(height: 12),

          // --- Documents Card ---
          _sectionCard(
            context,
            title: "Documents",
            children: [
              _docRow("Registration Certificate", getDoc("registration")),
              _docRow("CR12 Form", getDoc("cr12"), optional: true),
            ],
          ),

          const SizedBox(height: 20),

          // --- Info ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "By submitting, you confirm all details are accurate and verifiable.",
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

  // --- Section Card ---
  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.p.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // --- Info Row ---
  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- Document Row ---
  Widget _docRow(String label, String? file, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label)),
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: file != null ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    file != null
                        ? "Uploaded"
                        : optional
                        ? "Not provided"
                        : "Missing",
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
