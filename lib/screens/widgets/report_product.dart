import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '/core/utils/logger.dart';
import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

class ReportProductDialog extends StatefulWidget {
  final String productName;

  const ReportProductDialog({super.key, required this.productName});

  @override
  State<ReportProductDialog> createState() => _ReportProductDialogState();
}

class _ReportProductDialogState extends State<ReportProductDialog> {
  final _commentController = TextEditingController();
  String? _selectedReason;
  bool _loading = false;

  final _reasons = [
    "Illegal Content",
    "Harassment",
    "Sexual Content",
    "Violence",
    "IP Violation",
    "Spam",
    "Privacy Issue",
    "Other",
  ];

  Future<void> _submit() async {
    if (_selectedReason == null || _selectedReason!.isEmpty) {
      topSnackBar(context, "Please select a reason", type: TopSnackType.error);
      return;
    }

    setState(() => _loading = true);

    try {
      final client = sl<APIClient>().client;

      // get logged in user email from AuthProvider
      final authProvider = context.read<AuthProvider>();
      final loggedInEmail = authProvider.user?.username ?? "anonymous";

      appLogger.i("Logged in as: $loggedInEmail");

      final response = await client.post(
        ApiRoutes.reportProduct,
        queryParameters: {
          "product": widget.productName,
          "reason": _selectedReason,
          "comment": _commentController.text,
          "reported_by": loggedInEmail,
        },
      );

      final data = response.data['data'];

      appLogger.i("Data: ${data.toString()}");

      if (mounted) {
        appLogger.i("Worked well");
        context.pop(true);
        topSnackBar(
          context,
          data != null && data is Map && data['name'] != null
              ? "Report submitted successfully ✅"
              : "Report submitted ✅",
          type: TopSnackType.success,
        );
      }
    } on DioException catch (e, s) {
      appLogger.e("Report product API failed", error: e, stackTrace: s);
      if (mounted) {
        topSnackBar(
          context,
          "Failed to report. Please try again later.",
          type: TopSnackType.error,
        );
      }
    } catch (e, s) {
      appLogger.e(
        "Unexpected error in report product",
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        topSnackBar(
          context,
          "Something went wrong. Please try again later.",
          type: TopSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Report Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: const InputDecoration(
              labelText: "Reason *",
              border: OutlineInputBorder(),
            ),
            items:
                _reasons
                    .map(
                      (reason) =>
                          DropdownMenuItem(value: reason, child: Text(reason)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedReason = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: "Additional Details *",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child:
              _loading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Report"),
        ),
      ],
    );
  }
}
