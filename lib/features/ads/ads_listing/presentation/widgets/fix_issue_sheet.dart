import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showFixIssueSheet({
  required BuildContext context,
  required WidgetRef ref,
  required AOSAdListItem ad,
  required Future<bool?> Function() onEdit,
}) async {
  final result = await ref.read(adsApiProvider).getMyAd(adId: ad.id);
  if (!context.mounted) return false;

  Map<String, dynamic> item = const {};
  String? loadError;
  result.fold((failure) => loadError = failure.message, (json) {
    final data = asJsonMap(json['data']);
    item = asJsonMap(data['item']);
  });

  final explanation = _firstText(item, const [
    'decline_reason',
    'rejection_reason',
    'review_reason',
    'moderation_reason',
    'status_reason',
    'issue_message',
    'admin_feedback',
    'review_notes',
  ]);
  final affectedFields = _stringList(
    item['required_corrections'] ?? item['rejected_fields'],
  );
  final colors = context.appColors;

  final edited = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fix listing issue', style: sheetContext.h4),
            const SizedBox(height: 8),
            Text(
              ad.title.trim().isEmpty ? 'Listing ${ad.id}' : ad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sheetContext.pStrong,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .18),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Current status: ${item['status'] ?? 'Declined'}',
                      style: sheetContext.pStrong,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('What needs attention', style: sheetContext.h5),
            const SizedBox(height: 8),
            Text(
              explanation ??
                  loadError ??
                  'This listing requires changes before it can be approved. '
                      'Review the listing details and update any incomplete or '
                      'invalid information.',
              style: sheetContext.p.copyWith(height: 1.45),
            ),
            if (affectedFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Affected fields', style: sheetContext.pStrong),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: affectedFields
                    .map(
                      (field) => Chip(
                        avatar: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(field),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.btnText,
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetContext, false);
                      final changed = await onEdit();
                      if (context.mounted && (changed ?? false)) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Ad'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return edited ?? false;
}

String? _firstText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return null;
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? const [] : <String>[text];
}
