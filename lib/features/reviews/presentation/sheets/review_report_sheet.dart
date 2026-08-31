import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_report/data/report_ad_api_provider.dart';
import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';
import 'package:africaonlinestores/features/ads/ads_report/presentation/widgets/report_reason_tile.dart';
import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showReviewReportSheet(
  BuildContext context, {
  required String reviewId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ReviewReportSheet(reviewId: reviewId),
  );
}

class _ReviewReportSheet extends ConsumerStatefulWidget {
  const _ReviewReportSheet({required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<_ReviewReportSheet> createState() => _ReviewReportSheetState();
}

class _ReviewReportSheetState extends ConsumerState<_ReviewReportSheet> {
  final _detailsController = TextEditingController();

  List<ReportReason> _reasons = const [];
  String? _selectedReason;
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    final result = await ref.read(reportAdApiProvider).listReportReasons();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = failure.message;
        });
      },
      (reasons) {
        setState(() {
          _loading = false;
          _error = null;
          _reasons = reasons;
        });
      },
    );
  }

  Future<void> _submit() async {
    final reason = _selectedReason;
    if (reason == null || _submitting) return;

    setState(() => _submitting = true);

    final result = await ref
        .read(reviewApiProvider)
        .reportReview(
          reviewId: widget.reviewId,
          reason: reason,
          details: _detailsController.text.trim(),
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _submitting = false);
        ShowSnack(context, failure.message).error();
      },
      (_) {
        ShowSnack(context, 'Report submitted').success();
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Report review', style: context.h5)),
                IconButton(
                  tooltip: 'Close report review',
                  onPressed: _submitting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the reason that best describes the problem.',
              style: context.pMuted,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _ErrorState(message: _error!, onRetry: _loadReasons)
                  : _reasons.isEmpty
                  ? Center(
                      child: Text(
                        'No report reasons available right now.',
                        style: context.pMuted,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _reasons.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: colors.border),
                      itemBuilder: (context, index) {
                        final reason = _reasons[index];
                        return ReportReasonTile(
                          label: reason.title,
                          icon: Icons.flag_outlined,
                          selected: _selectedReason == reason.id,
                          mutedColor: colors.textMuted,
                          onTap: () {
                            if (_submitting) return;
                            setState(() => _selectedReason = reason.id);
                          },
                        );
                      },
                    ),
            ),
            if (!_loading && _error == null) ...[
              const SizedBox(height: 14),
              Text('Additional details (optional)', style: context.pStrong),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  hintText: 'Add any details that may help with the report.',
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Submit Report',
                loading: _submitting,
                onPressed: _selectedReason == null || _submitting
                    ? null
                    : _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: context.pMuted),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
