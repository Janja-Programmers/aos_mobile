import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/logger.dart';
import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

class ReportProductDialog extends StatefulWidget {
  final String webItem;
  final String itemCode;

  const ReportProductDialog({
    super.key,
    required this.webItem,
    required this.itemCode,
  });

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

      final response = await client.post(
        ApiRoutes.reportProduct,
        queryParameters: {
          "web_item": widget.webItem,
          "reason": _selectedReason,
          "comment": _commentController.text,
          "item": widget.itemCode,
        },
      );

      final data = response.data['data'];

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
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400, // keeps dialog width consistent
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  labelText: "Reason *",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items:
                    _reasons
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Additional Details",
                  alignLabelWithHint: true,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child:
              _loading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text("Submit"),
        ),
      ],
    );
  }
}
