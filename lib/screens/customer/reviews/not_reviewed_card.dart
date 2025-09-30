import 'package:flutter/material.dart';

class ProductNotReviewedCard extends StatelessWidget {
  final VoidCallback? onRate;
  final Widget? titleRow;

  const ProductNotReviewedCard({super.key, this.onRate, this.titleRow});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use the passed title row if available
        if (titleRow != null) titleRow!,
        const SizedBox(height: 16),

        // Average rating section
        Center(
          child: Column(
            children: const [
              Text(
                "0",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              Text(
                "0 ratings",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, color: Colors.amber, size: 24),
                  Icon(Icons.star_border, color: Colors.amber, size: 24),
                  Icon(Icons.star_border, color: Colors.amber, size: 24),
                  Icon(Icons.star_border, color: Colors.amber, size: 24),
                  Icon(Icons.star_border, color: Colors.amber, size: 24),
                ],
              ),
              SizedBox(height: 4),
              Text(
                "0 out of 5",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Rating distribution bars (all zero)
        Column(
          children: List.generate(5, (i) {
            final star = 5 - i;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text("$star star"),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.black87,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("0%"),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 20),
        const Text(
          "No Reviews",
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }
}
