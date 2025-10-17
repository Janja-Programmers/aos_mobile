// features/reviews/utils/review_dialogs.dart

import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';

import '/screens/customer/report/report_product.dart';
import 'rate_product.dart';

Future<void> openRateDialog(
  BuildContext context,
  String itemCode, {
  Future<void> Function()? onAfterSubmit,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => RateProductDialog(productName: itemCode),
  );

  if (result == true) {
    topSnackBar(context, "Review submitted successfully ✅");
    if (onAfterSubmit != null) await onAfterSubmit();
  }
}

Future<void> openReportDialog(
  BuildContext context,
  String webItem,
  String itemCode, {
  Future<void> Function()? onAfterReport,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ReportProductDialog(webItem: webItem, itemCode: itemCode),
  );

  if (result == true) {
    topSnackBar(context, "Report submitted successfully 🚨");
    if (onAfterReport != null) await onAfterReport();
  }
}
