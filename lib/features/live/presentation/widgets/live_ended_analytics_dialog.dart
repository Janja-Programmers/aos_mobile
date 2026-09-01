import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/presentation/live_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter/material.dart';

Future<void> showLiveEndedAnalyticsDialog(
  BuildContext context, {
  required LiveStream live,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .88),
    builder: (dialogContext) => LiveEndedAnalyticsDialog(live: live),
  );
}

class LiveEndedAnalyticsDialog extends StatelessWidget {
  const LiveEndedAnalyticsDialog({super.key, required this.live});

  final LiveStream live;

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: const Color(0xFF1D1D1D),
        shadowColor: Colors.black,
        elevation: 24,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Colors.white24, width: 1.2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .20),
                      shape: BoxShape.circle,
                      border: Border.all(color: primary.withValues(alpha: .55)),
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.liveEndedTitle,
                    textAlign: TextAlign.center,
                    style: context.h4.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.liveEndedOwnerMessage,
                    textAlign: TextAlign.center,
                    style: context.p.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            value: humanizeCount(live.peakViewers),
                            label: context.l10n.livePeak,
                          ),
                        ),
                        const SizedBox(
                          height: 44,
                          child: VerticalDivider(color: Colors.white12),
                        ),
                        Expanded(
                          child: _Metric(
                            value: humanizeCount(live.uniqueViewers),
                            label: context.l10n.liveViewersMetric,
                          ),
                        ),
                        const SizedBox(
                          height: 44,
                          child: VerticalDivider(color: Colors.white12),
                        ),
                        Expanded(
                          child: _Metric(
                            value: humanizeCount(live.reactionCount),
                            label: context.l10n.liveReactionsMetric,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('live_analytics_done_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: Text(
                        context.l10n.liveDone,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.h5.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.p.copyWith(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
