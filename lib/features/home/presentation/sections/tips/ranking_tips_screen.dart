import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/presentation/components/tips/tip_card.dart';
import 'package:africaonlinestores/features/home/presentation/components/tips/tip_screen.dart';

class RankingTipsScreen extends StatelessWidget {
  const RankingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TipsScreen(
      title: "Ranking Tips",
      subtitle: "Boost your visibility and sales",
      icon: Icons.lightbulb_outline,
      headerColor: Color(0xFFF5B041),
      children: [
        TipCard(
          icon: Icons.star_outline,
          iconBg: Color(0xFFFFF3CD),
          iconColor: Colors.orange,
          title: "Complete Your Profile",
          description:
              "Add a profile photo, verify your phone number, and fill in all details. Complete profiles rank 40% higher in search results.",
        ),
        TipCard(
          icon: Icons.verified_outlined,
          iconBg: Color(0xFFE3F2FD),
          iconColor: Colors.blue,
          title: "Get Verified",
          description:
              "Verify your identity and business. Verified sellers get a trust badge and appear higher in listings.",
        ),
        TipCard(
          icon: Icons.thumb_up_alt_outlined,
          iconBg: Color(0xFFE8F5E9),
          iconColor: Colors.green,
          title: "Collect Positive Reviews",
          description:
              "Deliver great service to earn 5-star reviews. Sellers with more positive reviews rank higher.",
        ),
        TipCard(
          icon: Icons.refresh,
          iconBg: Color(0xFFFFF8E1),
          iconColor: Colors.amber,
          title: "Keep Listings Fresh",
          description:
              "Update your ads regularly. Fresh listings get priority in search results and category pages.",
        ),
        TipCard(
          icon: Icons.flash_on_outlined,
          iconBg: Color(0xFFF3E5F5),
          iconColor: Colors.purple,
          title: "Respond Quickly",
          description:
              "Fast response times improve your seller score. Aim to reply within 1 hour during business hours.",
        ),
        TipCard(
          icon: Icons.sell_outlined,
          iconBg: Color(0xFFE0F2F1),
          iconColor: Colors.teal,
          title: "Price Competitively",
          description:
              "Well-priced items get more views and engagement. Research similar listings before setting your price.",
        ),
        TipCard(
          icon: Icons.image,
          iconBg: Color(0xFFFCE4EC),
          iconColor: Colors.pink,
          title: "Use Quality Images",
          description:
              "Listings with 5+ high-quality photos get 3x more views. Show all angles and details clearly.",
        ),
        TipCard(
          icon: Icons.category_outlined,
          iconBg: Color(0xFFE8EAF6),
          iconColor: Colors.indigo,
          title: "Choose Correct Categories",
          description:
              "Place items in the right category and subcategory. Miscategorized items rank lower in search.",
        ),
      ],
    );
  }
}
