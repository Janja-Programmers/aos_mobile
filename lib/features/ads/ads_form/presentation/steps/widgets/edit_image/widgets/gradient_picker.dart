import 'package:flutter/material.dart';

class GradientPicker extends StatelessWidget {
  const GradientPicker({super.key, required this.onSelect});

  final Function(List<Color>) onSelect;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [Colors.orange, Colors.pink],
      [Colors.blue, Colors.purple],
      [Colors.green, Colors.teal],
      [Colors.black, Colors.grey],
      [Colors.red, Colors.orange],
      [Colors.cyan, Colors.blue],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Gradients"),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final g = gradients[i];

              return GestureDetector(
                onTap: () => onSelect(g),
                child: Container(
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(colors: g),
                  ),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: gradients.length,
          ),
        ),
      ],
    );
  }
}
