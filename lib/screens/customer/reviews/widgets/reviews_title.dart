import 'package:flutter/material.dart';

enum ReviewAction { review, report }

class ReviewsTitleRow extends StatelessWidget {
  final VoidCallback onReview;
  final VoidCallback onReport;

  const ReviewsTitleRow({
    super.key,
    required this.onReview,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: PopupMenuButton<ReviewAction>(
            onSelected: (value) {
              switch (value) {
                case ReviewAction.review:
                  onReview();
                  break;
                case ReviewAction.report:
                  onReport();
                  break;
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: ReviewAction.review,
                    child: Text("✍️ Review product"),
                  ),
                  PopupMenuItem(
                    value: ReviewAction.report,
                    child: Text("🚩 Report product"),
                  ),
                ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Action",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
