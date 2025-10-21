import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';
import '/core/di/service_locator.dart';

import '/features/reviews/entity.dart';
import '/features/reviews/remote.dart';

import 'ratings_selector.dart';

class RateProductDialog extends StatefulWidget {
  final String webItem;
  final String itemCode;

  const RateProductDialog({
    super.key,
    required this.webItem,
    required this.itemCode,
  });

  @override
  State<RateProductDialog> createState() => _RateProductDialogState();
}

class _RateProductDialogState extends State<RateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();

  int _rating = 0;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      if (_rating == 0) {
        topSnackBar(
          context,
          "Please select a star rating",
          type: TopSnackType.error,
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final remote = sl<ReviewsRemote>();

      final normalizedRating = (_rating / 5).clamp(0.0, 1.0);

      await remote.postReview(
        webItem: widget.webItem,
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        rating: normalizedRating,
      );

      // Construct a Review entity to return
      final newReview = Review(
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        rating: _rating.toDouble(),
        customer: '',
        publishedOn: '',
      );

      if (!mounted) return;

      // Pass the Review back to caller
      context.pop(newReview);

      topSnackBar(
        context,
        "Review submitted successfully!",
        type: TopSnackType.success,
      );
    } catch (e) {
      if (mounted) {
        topSnackBar(
          context,
          "Failed to submit review. Please try again later.",
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
      title: const Text("Write a review"),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: maxDialogWidth,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Overall rating",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                StarRatingSelector(
                  rating: _rating,
                  onChanged: (val) => setState(() => _rating = val),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Headline *",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator:
                      (val) =>
                          val == null || val.trim().isEmpty
                              ? "Please enter a headline"
                              : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: "Comment (optional)",
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
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
