import 'package:flutter/material.dart';

class BackgroundPicker extends StatelessWidget {
  const BackgroundPicker({super.key, required this.onSelect});

  final Function(Color?) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.brown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Background Color"),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final c = colors[i];

              return GestureDetector(
                onTap: () => onSelect(c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: colors.length,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => onSelect(null),
            child: const Row(
              children: [
                Icon(Icons.layers_clear),
                SizedBox(width: 8),
                Text("Transparent"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
