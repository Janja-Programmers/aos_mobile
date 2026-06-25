import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

Future<void> showReportShortSheet({
  required BuildContext context,
  required String shortId,
  required Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _ReportShortSheet(shortId: shortId, onSubmit: onSubmit),
  );
}

class _ReportShortSheet extends ConsumerStatefulWidget {
  final String shortId;
  final Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onSubmit;

  const _ReportShortSheet({required this.shortId, required this.onSubmit});

  @override
  ConsumerState<_ReportShortSheet> createState() => _ReportShortSheetState();
}

class _ReportShortSheetState extends ConsumerState<_ReportShortSheet> {
  final _detailsController = TextEditingController();
  List<ReportReason> _reasons = const [];
  String? _selectedReasonId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadReasons() async {
    final result = await ref.read(shortsReportApiProvider).listReportReasons();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _reasons = const [];
        });
        ShowSnack(context, failure.message).error();
      },
      (reasons) {
        setState(() {
          _isLoading = false;
          _reasons = reasons;
        });
      },
    );
  }

  Future<void> _submit() async {
    final reason = _selectedReasonId;
    if (reason == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final error = await widget.onSubmit(
      shortId: widget.shortId,
      reason: reason,
      details: _detailsController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (error != null) {
      ShowSnack(context, error).error();
      return;
    }

    ShowSnack(context, 'Report submitted').success();
    Navigator.pop(context);
  }

  IconData _iconForReason(ReportReason reason) {
    switch (reason.id) {
      case 'Spam':
        return Icons.report_gmailerrorred_outlined;
      case 'Harassment or abuse':
        return Icons.person_off_outlined;
      case 'Nudity or sexual content':
      case 'Inappropriate content':
        return Icons.visibility_off_outlined;
      case 'Violence or dangerous content':
        return Icons.warning_amber_rounded;
      case 'Scam or fraud':
      case 'Suspected scam or fraud':
        return Icons.shield_outlined;
      case 'Other':
        return Icons.more_horiz_rounded;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    Expanded(child: Text('Report Short', style: context.h5)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose the reason that best describes the issue.',
                              style: context.pMuted,
                            ),
                            const SizedBox(height: 14),
                            if (_reasons.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  'No report reasons are available right now.',
                                  style: context.pMuted,
                                ),
                              )
                            else
                              ..._reasons.map((reason) {
                                final selected = reason.id == _selectedReasonId;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedReasonId = reason.id;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? colors.primary.withOpacity(.09)
                                            : colors.surface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: selected
                                              ? colors.primary
                                              : colors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _iconForReason(reason),
                                            color: selected
                                                ? colors.primary
                                                : colors.textMuted,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              reason.title,
                                              style: context.pStrong,
                                            ),
                                          ),
                                          if (selected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: colors.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 16),
                            Text(
                              'Additional details (optional)',
                              style: context.pStrong,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _detailsController,
                              maxLength: 500,
                              minLines: 4,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText:
                                    'Add more context to help moderation review this short...',
                                hintStyle: context.pMuted,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedReasonId == null || _isSubmitting
                        ? null
                        : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit report'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
