import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/constants/const.dart';
import '/core/utils/api_client.dart';
import '/core/utils/snackbar.dart';

class RateProductDialog extends StatefulWidget {
  final String productName;

  const RateProductDialog({super.key, required this.productName});

  @override
  State<RateProductDialog> createState() => _RateProductDialogState();
}

class _RateProductDialogState extends State<RateProductDialog> {
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 3;

  bool _loading = false;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final client = await APIClient.create();
      await client.client.post(
        ApiRoutes.addReview,
        data: {
          "web_item": widget.productName,
          "title": _titleController.text,
          "rating": _rating,
          "comment": _commentController.text,
        },
      );

      if (mounted) {
        (context).pop(true);
        topSnackBar(
          context,
          "Review submitted successfully!",
          type: TopSnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        topSnackBar(
          context,
          "Failed to submit review: $e",
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
      title: const Text("Rate Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: _rating.toStringAsFixed(1),
            onChanged: (v) => setState(() => _rating = v),
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "Comment"),
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
          child:
              _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text("Submit"),
        ),
      ],
    );
  }
}
