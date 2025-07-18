import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/const.dart';
import '/core/utils/snackbar.dart';

import '/features/stock/domain/entity/stock.dart';
import '/features/stock/providers/read.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

Future<void> cancelStockEntry(
  BuildContext context,
  StockEntry submitted,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cancel Entry?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'This action cannot be undone. Are you sure you want to cancel this stock entry?',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
  );

  if (confirmed != true) return;

  final apiClient = sl<APIClient>();
  const cancelDocApi = ApiRoutes.cancelDoc;
  final detailProvider = context.read<StockEntryDetailProvider>();

  try {
    await apiClient.client.post(
      cancelDocApi,
      data: {"doctype": "Stock Intake", "name": submitted.id},
    );

    if (!context.mounted) return;

    topSnackBar(
      context,
      'Stock Entry cancelled successfully',
      type: TopSnackType.success,
    );

    await detailProvider.fetchById(submitted.id);
    context.pop(true);
  } catch (e) {
    debugPrint('❌ Cancel Stock Entry error: $e');

    if (!context.mounted) return;

    topSnackBar(
      context,
      'Failed to cancel entry. Please try again.',
      type: TopSnackType.error,
    );
  }
}
