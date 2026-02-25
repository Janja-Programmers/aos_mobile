import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';
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

  ReportReasonKey? _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _detailsCtrl.addListener(() => setState(() {}));
  }

  List<_ReportReason> get _reasons => const [
    _ReportReason(
      key: ReportReasonKey.misleading,
      label: 'Misleading or Inaccurate\nDescription',
      icon: Icons.description_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.prohibited,
      label: 'Prohibited or Restricted Item',
      icon: Icons.block_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.scam,
      label: 'Suspected Scam or Fraud',
      icon: Icons.shield_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.inappropriate,
      label: 'Inappropriate Content',
      icon: Icons.report_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.wrongCategory,
      label: 'Wrong Category or Pricing',
      icon: Icons.category_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.duplicate,
      label: 'Duplicate Listing',
      icon: Icons.content_copy_outlined,
    ),
    _ReportReason(
      key: ReportReasonKey.other,
      label: 'Other',
      icon: Icons.more_horiz,
    ),
  ];

  bool get _canSubmit => _selected != null && !_loading;

  Future<void> _submit() async {
    if (_selected == null) {
      ShowSnack(context, 'Please select a reason').error();
      return;
    }

    setState(() => _loading = true);

    try {
      // TODO: Call your API here (example):
      // final res = await ref.read(adsApiProvider).reportProduct(
      //   productId: widget.productId,
      //   reason: _selected!.name,
      //   details: _detailsCtrl.text.trim(),
      // );
      //
      // res.fold(
      //   (f) => ShowSnack(context, f.message).error(),
      //   (_) { ...success... },
      // );

      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        ShowSnack(context, 'Report submitted').success();
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ShowSnack(context, 'Failed to submit report').error();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dividerColor = Theme.of(context).dividerColor.withOpacity(.55);
    final muted = Theme.of(context).hintColor;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: Text('Report Product', style: context.h5),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Reasons Card
                  Container(
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(_reasons.length, (i) {
                        final r = _reasons[i];
                        final isSelected = _selected == r.key;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _selected = r.key),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(r.icon, size: 20, color: muted),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(r.label, style: context.p),
                                    ),
                                    _RadioCircle(
                                      selected: isSelected,
                                      color: muted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i != _reasons.length - 1)
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

                  // ✅ Additional Details
                  Text('Additional details (optional)', style: context.pStrong),
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
                      counterText: "", // hide default counter
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

          // ✅ Bottom Submit Button (disabled until reason selected)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                text: 'Submit Report',
                loading: _loading,
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
    _detailsCtrl.dispose();
    super.dispose();
  }
}

enum ReportReasonKey {
  misleading,
  prohibited,
  scam,
  inappropriate,
  wrongCategory,
  duplicate,
  other,
}

class _ReportReason {
  const _ReportReason({
    required this.key,
    required this.label,
    required this.icon,
  });

  final ReportReasonKey key;
  final String label;
  final IconData icon;
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final border = color.withOpacity(.6);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: border,
                ),
              ),
            )
          : null,
    );
  }
}
