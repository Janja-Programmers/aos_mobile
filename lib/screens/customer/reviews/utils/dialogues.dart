import 'package:flutter/material.dart';

import '/core/utils/snackbar.dart';

import '/screens/customer/report/report_product.dart';

import 'rate_product.dart';

Future<bool?> openRateDialog(
  BuildContext context,
  String itemCode,
  String webItem, {
  Future<void> Function()? onAfterSubmit,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => RateProductDialog(webItem: webItem, itemCode: itemCode),
  );

  if (result == true) {
    topSnackBar(context, "Review submitted successfully ✅");
    if (onAfterSubmit != null) await onAfterSubmit();
  }

  return result; // ✅ Return the result so caller can act on it
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
