import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/files/data/files_api_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/seller/seller_verification/domain/verification_document.dart';

import 'package:africaonlinestores/shared/media/media_helper.dart';

class DocumentsStep extends ConsumerWidget {
  const DocumentsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerVerificationControllerProvider);
    final controller = ref.read(sellerVerificationControllerProvider.notifier);

    final documents = state.data.documents;
    final colors = context.appColors;

    // Helpers to access docs safely
    VerificationDocument? getDoc(String type) {
      try {
        return documents.firstWhere((e) => e.documentType == type);
      } catch (_) {
        return null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // --- Registration ---
          _uploadCard(
            context: context,
            title: "Upload registration certificate",
            subtitle: "PDF, JPG, or PNG (max 5MB)",
            file: getDoc("registration")?.attachment,
            onTap: () async {
              final file = await MediaHelper.pickDocument();
              if (file == null) return;

              final url = await MediaHelper.uploadSingle(
                ref: ref,
                file: file,
                uploadFn: (f) =>
                    ref.read(filesApiProvider).uploadMedia(file: f),
              );

              if (url == null) return;

              final existing = getDoc("registration");

              final doc = VerificationDocument(
                documentType: "registration",
                attachment: url,
              );

              if (existing == null) {
                controller.addDocument(doc);
              } else {
                final index = documents.indexOf(existing);
                controller.updateDocument(index, doc);
              }
            },
          ),

          const SizedBox(height: 16),

          // --- CR12 Label ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "CR12 Form (Optional)",
              style: context.p.copyWith(color: colors.textMuted),
            ),
          ),

          const SizedBox(height: 8),

          // --- CR12 ---
          _uploadCard(
            context: context,
            title: "Upload CR12 form",
            subtitle: "PDF, JPG, or PNG (max 5MB)",
            file: getDoc("cr12")?.attachment,
            onTap: () async {
              final file = await MediaHelper.pickDocument();
              if (file == null) return;

              final url = await MediaHelper.uploadSingle(
                ref: ref,
                file: file,
                uploadFn: (f) =>
                    ref.read(filesApiProvider).uploadMedia(file: f),
              );

              if (url == null) return;

              final existing = getDoc("cr12");

              final doc = VerificationDocument(
                documentType: "cr12",
                attachment: url,
              );

              if (existing == null) {
                controller.addDocument(doc);
              } else {
                final index = documents.indexOf(existing);
                controller.updateDocument(index, doc);
              }
            },
          ),

          const SizedBox(height: 20),

          // --- Accepted Docs ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Accepted Documents",
                      style: context.p.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _Bullet(text: "Certificate of Incorporation"),
                const _Bullet(text: "Business Registration Certificate"),
                const _Bullet(text: "Single Business Permit"),
                const _Bullet(text: "Trade License"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- Info ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Tax documents (KRA PIN) and business address can be added later in your storefront settings.",
                    style: context.p.copyWith(
                      fontSize: 12,
                      color: Colors.orange.shade800,
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

  // --- Upload Card ---
  Widget _uploadCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String? file,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.p),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.p.copyWith(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Bullet ---
class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
