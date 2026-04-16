import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:africaonlinestores/features/shorts/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/feeds/widgets/short_grid_card.dart';

class InspirationGrid extends ConsumerWidget {
  const InspirationGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 🔴 TEMP: Dummy JSON → real model
    final shorts = List.generate(
      10,
      (index) => ShortModel.fromJson({
        'id': '$index',
        'caption': 'Sample caption for short $index',
        'hashtags': [],
        'thumbnail_url': null,
        'playback_url': null,
        'duration_seconds': 0,
        'ranking_score': 0,
        'posted_on': null,
        'is_ready': true,
        'is_processing': false,
        'is_failed': false,

        /// Metrics fields (adjust if needed)
        'likes': index * 120,
      }),
    );

    /// ✅ Always filter invalid content (REAL RULE)
    final validShorts = shorts.where((s) => s.isReady && !s.isFailed).toList();

    if (validShorts.isEmpty) {
      return const Center(child: Text('No content yet'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: validShorts.length,
        itemBuilder: (context, index) {
          return ShortGridCard(short: validShorts[index]);
        },
      ),
    );
  }
}
