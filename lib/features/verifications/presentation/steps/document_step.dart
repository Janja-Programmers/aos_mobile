import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/verifications/controllers/verification_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_document.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          // --- Header ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.video_file_outlined,
                  size: 36,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Verification Documents',
                style: context.h5.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: 6),

              Text(
                'Upload your official business registration certificate to verify your business is legally registered',
                style: context.p.copyWith(color: colors.textMuted),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- REGISTRATION CERTIFICATE Label ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Certificate of Registration *', style: context.p),
          ),

          const SizedBox(height: 8),

          // --- REGISTRATION CERTIFICATE ---
          _uploadCard(
            context: context,
            title: 'Upload registration certificate',
            subtitle: 'PDF, JPG, or PNG (max 20MB)',
            file: getDoc('registration_certificate')?.attachment,
            isUploading: state.uploadingDocs.contains(
              'registration_certificate',
            ),
            onTap: () async {
              const type = 'registration_certificate';

              if (state.uploadingDocs.contains(type)) return;

              final media = await ref
                  .read(mediaAcquisitionServiceProvider)
                  .pickDocument(useCase: MediaUseCase.verificationDocument);
              if (media == null) return;

              controller.setUploading(type, true);

              try {
                final result = await ref
                    .read(mediaUploadCoordinatorProvider)
                    .upload(
                      media: media,
                      useCase: MediaUseCase.verificationDocument,
                      discardSourceWhenDone: true,
                    );
                final uploaded = result.rightOrNull;

                if (uploaded == null) {
                  if (context.mounted) {
                    ShowSnack(context, 'Upload failed. Try again').error();
                  }
                  return;
                }

                final displayValue = uploaded.url.isNotEmpty
                    ? uploaded.url
                    : uploaded.mediaId;

                final existing = getDoc(type);

                final doc = VerificationDocument(
                  documentType: type,
                  attachment: displayValue,
                  mediaId: uploaded.mediaId,
                );

                if (existing == null) {
                  controller.addDocument(doc);
                } else {
                  final index = documents.indexOf(existing);
                  controller.updateDocument(index, doc);
                }
              } finally {
                await media.discard();
                controller.setUploading(type, false);
              }
            },
          ),

          const SizedBox(height: 20),

          // --- TAX ID Label ---
          Align(
            alignment: Alignment.centerLeft,
            child: Text('TAX ID: (KRA)', style: context.p),
          ),

          const SizedBox(height: 8),

          // --- REGISTRATION CERTIFICATE ---
          _uploadCard(
            context: context,
            title: 'Upload KRA',
            subtitle: 'PDF, JPG, or PNG (max 20MB)',
            file: getDoc('tax_id')?.attachment,
            isUploading: state.uploadingDocs.contains('tax_id'),
            onTap: () async {
              const type = 'tax_id';

              if (state.uploadingDocs.contains(type)) return;

              final media = await ref
                  .read(mediaAcquisitionServiceProvider)
                  .pickDocument(useCase: MediaUseCase.verificationDocument);
              if (media == null) return;

              controller.setUploading(type, true);

              try {
                final result = await ref
                    .read(mediaUploadCoordinatorProvider)
                    .upload(
                      media: media,
                      useCase: MediaUseCase.verificationDocument,
                      discardSourceWhenDone: true,
                    );
                final uploaded = result.rightOrNull;

                if (uploaded == null) {
                  if (context.mounted) {
                    ShowSnack(context, 'Upload failed. Try again').error();
                  }
                  return;
                }

                final displayValue = uploaded.url.isNotEmpty
                    ? uploaded.url
                    : uploaded.mediaId;

                final existing = getDoc(type);

                final doc = VerificationDocument(
                  documentType: type,
                  attachment: displayValue,
                  mediaId: uploaded.mediaId,
                );

                if (existing == null) {
                  controller.addDocument(doc);
                } else {
                  final index = documents.indexOf(existing);
                  controller.updateDocument(index, doc);
                }
              } finally {
                await media.discard();
                controller.setUploading(type, false);
              }
            },
          ),

          const SizedBox(height: 20),
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
    required bool isUploading,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    final isUploaded = file != null;

    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded
              ? colors.success.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? colors.success.withValues(alpha: 0.6)
                : colors.border,
          ),
        ),
        child: Row(
          children: [
            /// 🔹 LEADING ICON / LOADER
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded
                    ? colors.success.withValues(alpha: 0.15)
                    : colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isUploading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors.primary),
                      ),
                    )
                  : Icon(
                      isUploaded
                          ? Icons.check_circle
                          : Icons.description_outlined,
                      size: 20,
                      color: isUploaded ? colors.success : colors.textMuted,
                    ),
            ),

            const SizedBox(width: 12),

            /// 🔹 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploading
                        ? 'Uploading document...'
                        : isUploaded
                        ? 'Document uploaded successfully'
                        : title,
                    style: context.p.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploading
                        ? 'Please wait'
                        : isUploaded
                        ? _extractFileName(file)
                        : subtitle,
                    style: context.p.copyWith(
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 TRAILING ICON
            if (!isUploading)
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded ? colors.success : colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

String _extractFileName(String? url) {
  if (url == null || url.isEmpty) return '';

  final parts = url.split('/');
  return parts.isNotEmpty ? parts.last : url;
}

// --- Bullet ---
// class _Bullet extends StatelessWidget {
//   const _Bullet({required this.text});
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         children: [
//           const Text("• "),
//           Expanded(child: Text(text)),
//         ],
//       ),
//     );
//   }
// }
