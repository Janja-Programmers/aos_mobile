import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/ads_report/controllers/report_ad_controller.dart';
import 'package:africaonlinestores/features/ads/ads_report/presentation/widgets/report_reason_tile.dart';
import 'package:africaonlinestores/features/ads/ads_report/models/report_reason.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ReportAdScreen extends ConsumerStatefulWidget {
  const ReportAdScreen({super.key, required this.adId});

  final String adId;

  @override
  ConsumerState<ReportAdScreen> createState() => _ReportAdScreenState();
}

class _ReportAdScreenState extends ConsumerState<ReportAdScreen> {
  final _detailsCtrl = TextEditingController();

  String? _selectedReasonId;

  @override
  void initState() {
    super.initState();
    _detailsCtrl.addListener(_onDetailsChanged);

    Future.microtask(() {
      ref.read(reportAdControllerProvider.notifier).loadReasons();
    });
  }

  void _onDetailsChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    final state = ref.read(reportAdControllerProvider);
    return _selectedReasonId != null && !state.submitting;
  }

  Future<void> _submit() async {
    final reasonId = _selectedReasonId;
    if (reasonId == null) {
      ShowSnack(context, 'Please select a reason').error();
      return;
    }

    final res = await ref
        .read(reportAdControllerProvider.notifier)
        .submit(
          adId: widget.adId,
          reason: reasonId,
          details: _detailsCtrl.text.trim(),
        );

    if (!mounted) return;

    res.fold((f) => ShowSnack(context, f.message).error(), (_) {
      ShowSnack(context, 'Report submitted').success();
      Navigator.pop(context, true);
    });
  }

  IconData _iconForReason(ReportReason reason) {
    switch (reason.id) {
      case 'Misleading or inaccurate description':
        return Icons.description_outlined;
      case 'Prohibited or restricted item':
        return Icons.block_outlined;
      case 'Suspected scam or fraud':
        return Icons.shield_outlined;
      case 'Inappropriate content':
        return Icons.report_outlined;
      case 'Wrong category':
      case 'Wrong or misleading pricing':
        return Icons.category_outlined;
      case 'Duplicate ad':
        return Icons.content_copy_outlined;
      case 'Counterfeit or fake product':
        return Icons.gpp_bad_outlined;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dividerColor = Theme.of(context).dividerColor.withOpacity(.55);
    final muted = Theme.of(context).hintColor;

    final state = ref.watch(reportAdControllerProvider);
    final reasons = state.reasons;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Report Ad', style: context.h5),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: reasons.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No report reasons available right now.',
                                    style: context.pMuted,
                                  ),
                                )
                              : Column(
                                  children: List.generate(reasons.length, (i) {
                                    final reason = reasons[i];
                                    final isSelected =
                                        _selectedReasonId == reason.id;

                                    return Column(
                                      children: [
                                        ReportReasonTile(
                                          label: reason.title,
                                          icon: _iconForReason(reason),
                                          selected: isSelected,
                                          mutedColor: muted,
                                          onTap: () {
                                            setState(() {
                                              _selectedReasonId = reason.id;
                                            });
                                          },
                                        ),
                                        if (i != reasons.length - 1)
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: dividerColor,
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Additional details (optional)',
                          style: context.pStrong,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _detailsCtrl,
                          minLines: 5,
                          maxLines: 7,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText:
                                'Provide any additional information that help us review this report...',
                            filled: true,
                            fillColor: colors.white,
                            counterText: '',
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: dividerColor),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_detailsCtrl.text.length}/500',
                            style: context.pMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                text: 'Submit Report',
                loading: state.submitting,
                onPressed: _canSubmit ? _submit : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detailsCtrl.removeListener(_onDetailsChanged);
    _detailsCtrl.dispose();
    super.dispose();
  }
}
