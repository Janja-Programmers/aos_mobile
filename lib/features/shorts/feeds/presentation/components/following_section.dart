import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/following_shorts_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/suggested_sellers_section.dart';
import 'package:flutter/material.dart';

class FollowingSection extends StatelessWidget {
  const FollowingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SuggestedSellersSection(),

        SizedBox(height: 22),

        FollowingShortsSection(),
      ],
    );
  }
}
