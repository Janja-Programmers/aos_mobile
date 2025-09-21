import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';
import '/core/utils/snackbar.dart';

import 'ratings_selector.dart';

class RateProductDialog extends StatefulWidget {
  final String productName;

  const RateProductDialog({super.key, required this.productName});

  @override
  State<RateProductDialog> createState() => _RateProductDialogState();
}

class _RateProductDialogState extends State<RateProductDialog> {
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 3;

  bool _loading = false;
  Future<void> _submit() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final client = sl<APIClient>().client;
      final res = await client.post(
        ApiRoutes.addReview,
        data: {
          "web_item": widget.productName,
          "title": _titleController.text,
          "rating": _rating, // keep as int
          "comment": _commentController.text,
        },
      );

      appLogger.d("Res: ${res.data}");

      if (mounted) {
        context.pop(true);
        topSnackBar(
          context,
          res.data['message'] ?? "Review submitted successfully!",
          type: TopSnackType.success,
        );
      }
    } catch (e, s) {
      appLogger.e("Review submission failed", error: e, stackTrace: s);
      if (mounted) {
        topSnackBar(
          context,
          "Failed to submit review",
          type: TopSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxDialogHeight = screenSize.height * 0.6;
    final maxDialogWidth =
        screenSize.width > 500 ? 400.0 : screenSize.width * 0.9;

    return AlertDialog(
      title: const Text("Rate Product"),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: maxDialogWidth,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRatingSelector(
                rating: _rating,
                onChanged: (val) => setState(() => _rating = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: "Comment"),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child:
              _loading
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Submit"),
        ),
      ],
    );
  }
}
