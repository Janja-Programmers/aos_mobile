import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/components/tips/tip_card.dart';
import 'package:africaonlinestores/shared/components/tips/tip_screen.dart';
import 'package:flutter/material.dart';

class SellingTipsScreen extends StatelessWidget {
  const SellingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TipsScreen(
      title: 'Selling Tips',
      subtitle: 'Learn how to sell faster and get better prices',
      icon: Icons.lightbulb_outline,
      headerColor: colors.amber,
      children: [
        TipCard(
          icon: Icons.camera_alt_outlined,
          iconBg: colors.blue,
          iconColor: colors.blue,
          title: 'Take Great Photos',
          description:
              'Use natural lighting, show multiple angles, and keep backgrounds clean, items with clear photos sell 3x faster.',
        ),
        TipCard(
          icon: Icons.title,
          iconBg: colors.amber,
          iconColor: colors.amber,
          title: 'Write Ckear Titles',
          description:
              "Includebrand, model, size, and condition. Example: 'iPhone 14 Pro Max 2556B - New'.",
        ),
        TipCard(
          icon: Icons.description_outlined,
          iconBg: colors.success,
          iconColor: colors.success,
          title: 'Detailed descriptions',
          description:
              'Take photos from front, back, sides, and top. Include at least 5 photos per listing.',
        ),
        TipCard(
          icon: Icons.local_offer_outlined,
          iconBg: colors.blue,
          iconColor: Colors.purple,
          title: 'Price Competitively',
          description:
              'Research similar items before pricing. Competitive price attract more buyers and faster sales',
        ),

        TipCard(
          icon: Icons.category_outlined,
          iconBg: colors.success,
          iconColor: colors.success,
          title: 'Choose Right Category',
          description:
              'Price your item in the correct category so buyers can easily find it when browsing.',
        ),

        TipCard(
          icon: Icons.access_time_rounded,
          iconBg: colors.blue,
          iconColor: Colors.blueAccent,
          title: 'Post at Peak Times',
          description:
              'Post ads in the evening (6 - 9 PM) and weekends when more buyers are browsing.',
        ),

        TipCard(
          icon: Icons.messenger_outline,
          iconBg: colors.primary,
          iconColor: colors.primary,
          title: 'Respond Quickly',
          description:
              "Reply to inquiries within an hour. Fast responses show you're serious and build confidence.",
        ),

        TipCard(
          icon: Icons.refresh,
          iconBg: colors.amber,
          iconColor: colors.amber,
          title: 'Keep Listings Fresh',
          description:
              'Update your ads regularly. Refresh photos or adjust prices to stay visible in search results.',
        ),
      ],
    );
  }
}
