import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_models.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showShortAnalyticsSheet(
  BuildContext context, {
  required String shortId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ShortAnalyticsSheet(shortId: shortId),
  );
}

class ShortAnalyticsSheet extends ConsumerStatefulWidget {
  const ShortAnalyticsSheet({super.key, required this.shortId});

  final String shortId;

  @override
  ConsumerState<ShortAnalyticsSheet> createState() =>
      _ShortAnalyticsSheetState();
}

class _ShortAnalyticsSheetState extends ConsumerState<ShortAnalyticsSheet> {
  ShortAnalyticsResult? _result;
  String? _errorMessage;
  bool _loading = true;
  bool _refreshing = false;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_load());
    });
  }

  Future<void> _load({bool refresh = false}) async {
    if (_refreshing || (!refresh && !_loading && _result != null)) return;
    final generation = ++_requestGeneration;
    if (mounted) {
      setState(() {
        if (refresh) {
          _refreshing = true;
        } else {
          _loading = true;
        }
        _errorMessage = null;
      });
    }

    final response = await ref
        .read(shortsAnalyticsApiProvider)
        .shortAnalytics(shortId: widget.shortId);
    if (!mounted || generation != _requestGeneration) return;

    response.fold(
      (failure) {
        setState(() {
          _loading = false;
          _refreshing = false;
          _errorMessage = failure.message;
        });
      },
      (result) {
        setState(() {
          _result = result;
          _loading = false;
          _refreshing = false;
          _errorMessage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .86,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Short analytics', style: context.h5)),
                    IconButton(
                      tooltip: 'Close analytics',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                if (_loading && _result == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 56),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_result == null)
                  _InitialError(
                    message: _errorMessage ?? 'Analytics are unavailable.',
                    onRetry: () => unawaited(_load()),
                  )
                else ...<Widget>[
                  _CurrentTotalsGrid(summary: _result!.currentTotals),
                  const SizedBox(height: 16),
                  Text(_periodLabel(_result!), style: context.pStrong),
                  const SizedBox(height: 8),
                  _PerformanceCard(summary: _result!.totals),
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _errorMessage!,
                        style: context.small.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _refreshing
                        ? null
                        : () => unawaited(_load(refresh: true)),
                    icon: _refreshing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bar_chart_rounded),
                    label: Text(
                      _refreshing ? 'Refreshing…' : 'Refresh analytics',
                      style: AppTextStylesX(context).button,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentTotalsGrid extends StatelessWidget {
  const _CurrentTotalsGrid({required this.summary});

  final ShortsAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = <(String, int)>[
      ('Views', summary.views),
      ('Likes', summary.likes),
      ('Comments', summary.comments),
      ('Shares', summary.shares),
      ('Saves', summary.saves),
      ('Reposts', summary.reposts),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 3;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: metrics
                  .map(
                    (metric) => SizedBox(
                      width: width,
                      child: _MetricTile(label: metric.$1, value: metric.$2),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.elevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: context.smallMuted, maxLines: 1),
            const SizedBox(height: 4),
            Text(_humanize(value), style: context.pStrong),
          ],
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.summary});

  final ShortsAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Impressions', _humanize(summary.impressions)),
      ('Downloads', _humanize(summary.downloads)),
      ('Average watch', _duration(summary.avgWatchTimeMs)),
      ('Completion', _percent(summary.completionRate)),
      ('Engagement', _percent(summary.engagementRate)),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: rows
            .map(
              (row) => ListTile(
                dense: true,
                title: Text(row.$1, style: context.p),
                trailing: Text(row.$2, style: context.pStrong),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _InitialError extends StatelessWidget {
  const _InitialError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: <Widget>[
          const Icon(Icons.analytics_outlined, size: 44),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _humanize(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
}

String _duration(double milliseconds) {
  final seconds = (milliseconds / 1000).round();
  if (seconds <= 0) return '0s';
  final minutes = seconds ~/ 60;
  final remainder = seconds.remainder(60);
  if (minutes > 0) return '${minutes}m ${remainder}s';
  return '${seconds}s';
}

String _percent(double value) {
  final normalized = value <= 1 ? value * 100 : value;
  return '${normalized.clamp(0, 100).toStringAsFixed(1)}%';
}

String _periodLabel(ShortAnalyticsResult result) {
  final from = result.dateFrom;
  final to = result.dateTo;
  if (from == null || to == null) return 'Performance';
  String ymd(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
  return 'Performance · ${ymd(from)} – ${ymd(to)}';
}
