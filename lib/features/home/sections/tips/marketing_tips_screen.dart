import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/components/tips/tip_card.dart';
import 'package:africaonlinestores/features/home/components/tips/tip_screen.dart';

class MarketingTipsScreen extends StatelessWidget {
  const MarketingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TipsScreen(
      title: "Marketing Tips",
      subtitle: "Grow your sales and reach",
      icon: Icons.trending_up,
      headerColor: Color(0xFF49C27D),
      children: [
        TipCard(
          icon: Icons.share,
          iconBg: Color(0xFFE3F2FD),
          iconColor: Colors.blue,
          title: "Share on Social Media",
          description:
              "Share your listings on WhatsApp, Facebook, and Instagram. Social sharing can increase views by 5x.",
        ),
        TipCard(
          icon: Icons.campaign_outlined,
          iconBg: Color(0xFFFFF3CD),
          iconColor: Colors.orange,
          title: "Use Promoted Listings",
          description:
              "Boost your ads to appear at the top of search results. Promoted listings get 10x more visibility.",
        ),
        TipCard(
          icon: Icons.local_offer_outlined,
          iconBg: Color(0xFFE8F5E9),
          iconColor: Colors.green,
          title: "Offer Discounts",
          description:
              "Create limited-time offers to create urgency. Items with discounts sell 2x faster.",
        ),
        TipCard(
          icon: Icons.inventory_2_outlined,
          iconBg: Color(0xFFF3E5F5),
          iconColor: Colors.purple,
          title: "Bundle Products",
          description:
              "Offer package deals to increase average order value. Bundles attract buyers looking for value.",
        ),
        TipCard(
          icon: Icons.access_time,
          iconBg: Color(0xFFE0F2F1),
          iconColor: Colors.teal,
          title: "Time Your Posts",
          description:
              "Post during peak hours (6–9 PM weekdays, weekends). Timing can increase engagement by 40%.",
        ),
        TipCard(
          icon: Icons.refresh,
          iconBg: Color(0xFFFFF8E1),
          iconColor: Colors.amber,
          title: "Repost Regularly",
          description:
              "Refresh your listings every few days. Regular updates keep your items visible and relevant.",
        ),
        TipCard(
          icon: Icons.group_outlined,
          iconBg: Color(0xFFE8EAF6),
          iconColor: Colors.indigo,
          title: "Build Your Following",
          description:
              "Encourage buyers to follow your store. Followers get notified when you post new items.",
        ),
        TipCard(
          icon: Icons.bar_chart_outlined,
          iconBg: Color(0xFFFFF3CD),
          iconColor: Colors.orange,
          title: "Track Performance",
          description:
              "Monitor your listing views and messages. Use insights to optimize your selling strategy.",
        ),
      ],
    );
  }
}
