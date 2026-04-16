import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_model.dart';

class ShortGridCard extends StatelessWidget {
  final ShortModel short;

  const ShortGridCard({super.key, required this.short});

  static const _dummyImages = [
    'https://images.unsplash.com/photo-1492724441997-5dc865305da7',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
    'https://images.unsplash.com/photo-1521335629791-ce4aec67dd47',
    'https://images.unsplash.com/photo-1487412912498-0447578fcca8',
    'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
  ];

  @override
  Widget build(BuildContext context) {
    final caption = short.caption;

    /// 🔥 Pick image based on id (stable randomness)
    final imageUrl =
        short.thumbnailUrl ??
        _dummyImages[short.id.hashCode % _dummyImages.length];

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 Thumbnail (NO fixed height → Masonry magic)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
            ),

            /// 📝 Caption
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),

            /// ❤️ Metrics
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.favorite_border, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(10000),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 150,
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.play_arrow)),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}
