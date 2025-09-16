import 'package:africaonlinestores/core/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/const.dart';
import '../../core/utils/api_client.dart';

class ReportProductDialog extends StatefulWidget {
  final String productName;

  const ReportProductDialog({super.key, required this.productName});

  @override
  State<ReportProductDialog> createState() => _ReportProductDialogState();
}

class _ReportProductDialogState extends State<ReportProductDialog> {
  final _reasonController = TextEditingController();
  final _commentController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_reasonController.text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final client = await APIClient.create();
      await client.client.post(
        ApiRoutes.reportProduct,
        data: {
          "doc": {
            "doctype": "Reported Product",
            "product": widget.productName,
            "reported_by": "frappe.session.user",
            "reason": _reasonController.text,
            "comment": _commentController.text,
            "status": "Pending",
          },
        },
      );

      if (mounted) {
        context.pop(true);
        topSnackBar(
          context,
          "Report submitted successfully.",
          type: TopSnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        topSnackBar(context, "Failed to report: $e", type: TopSnackType.error);
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
        children: [
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(labelText: "Reason"),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "Comment (optional)"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child:
              _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text("Report"),
        ),
      ],
    );
  }
}
