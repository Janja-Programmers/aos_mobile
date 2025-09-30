import 'package:flutter/material.dart';

class StarRatingSelector extends StatelessWidget {
  final int rating;
  final Function(int) onChanged;

  const StarRatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive star size
    double starSize;
    if (screenWidth < 320) {
      starSize = 20; // very small devices
    } else if (screenWidth < 400) {
      starSize = 26;
    } else {
      starSize = 32;
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4, // space between stars
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: starSize,
          ),
        );
      }),
    );
  }
}
