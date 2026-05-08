import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/sellers/seller_verification/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/domain/verification.dart';

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

    final registrationCertificate = getDoc("registration_certificate");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔴 HEADER (matches design)
          Column(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  size: 36,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Review & Submit",
                style: context.h5.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 6),
              Text(
                "Review your business information before submitting for verification.",
                style: context.p.copyWith(color: colors.textMuted),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// 🧾 BUSINESS SUMMARY
          _businessSummaryCard(context, data),

          const SizedBox(height: 20),

          /// ✅ CHECKLIST
          _verificationChecklist(context, data, registrationCertificate),

          const SizedBox(height: 20),

          /// 🎯 BENEFITS
          _benefitsCard(context),

          const SizedBox(height: 16),

          /// 📌 DISCLAIMER
          _disclaimer(context),
        ],
      ),
    );
  }

  // --- BUSINESS CARD ---
  Widget _businessSummaryCard(BuildContext context, Verification data) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.store_mall_directory, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.businessName ?? "-",
                    style: context.h6.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    data.businessType ?? "-",
                    style: context.p.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: colors.border),

          const SizedBox(height: 12),
          _infoRow(context, "Category", data.businessCategory),
          _infoRow(context, "Phone Number", data.businessPhoneNumber),
          _infoRow(context, "Physical Location", data.physicalAddress),
        ],
      ),
    );
  }

  // --- CHECKLIST ---
  Widget _verificationChecklist(
    BuildContext context,
    Verification data,
    String? registrationCertificate,
  ) {
    final colors = context.appColors;

    final items = [
      (
        "Business Name, Type & Category",
        (data.businessName?.isNotEmpty ?? false) &&
            (data.businessType?.isNotEmpty ?? false) &&
            (data.businessCategory?.isNotEmpty ?? false),
      ),
      (
        "Phone Number, Email & Physical Location",
        (data.businessPhoneNumber?.isNotEmpty ?? false) &&
            (data.businessEmail?.isNotEmpty ?? false) &&
            (data.physicalAddress?.isNotEmpty ?? false),
      ),

      // Documents
      ("Verification Documents", (registrationCertificate != null)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification Checklist",
          style: context.h6.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        ...items.map(
          (e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  e.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: e.$2 ? colors.success : colors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.$1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- BENEFITS ---
  Widget _benefitsCard(BuildContext context) {
    final colors = context.appColors;

    final benefits = [
      "Verified business badge",
      "Higher visibility in search results",
      "Priority customer support",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: colors.blue),
              const SizedBox(width: 8),
              Text(
                "Business Verification Benefits",
                style: context.p.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: colors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DISCLAIMER ---
  Widget _disclaimer(BuildContext context) {
    final colors = context.appColors;

    return Text(
      "By submitting, you confirm that all information provided is accurate. "
      "Processing typically takes 2–5 business days.",
      style: context.p.copyWith(fontSize: 12, color: colors.textMuted),
    );
  }

  // --- ROW ---
  Widget _infoRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label, style: context.pMuted)),

          const SizedBox(width: 12),

          Expanded(
            flex: 6,
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
