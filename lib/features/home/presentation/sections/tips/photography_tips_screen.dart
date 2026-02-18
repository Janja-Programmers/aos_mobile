import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/presentation/components/tips/tip_card.dart';
import 'package:africaonlinestores/features/home/presentation/components/tips/tip_screen.dart';

class PhotographyTipsScreen extends StatelessWidget {
  const PhotographyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TipsScreen(
      title: "Photography Tips",
      subtitle: "Take photos that sell",
      icon: Icons.camera_alt_outlined,
      headerColor: Color(0xFF6FA8DC),
      children: [
        TipCard(
          icon: Icons.wb_sunny_outlined,
          iconBg: Color(0xFFFFF3CD),
          iconColor: Colors.orange,
          title: "Use Natural Light",
          description:
              "Photograph near windows during daylight. Natural light makes colors accurate and products look professional.",
        ),
        TipCard(
          icon: Icons.crop_square,
          iconBg: Color(0xFFE3F2FD),
          iconColor: Colors.blue,
          title: "Clean Background",
          description:
              "Use a plain white or neutral background. Cluttered backgrounds distract from your product.",
        ),
        TipCard(
          icon: Icons.view_in_ar,
          iconBg: Color(0xFFE8F5E9),
          iconColor: Colors.green,
          title: "Show All Angles",
          description:
              "Take photos from front, back, sides, and top. Include at least 5 photos per listing.",
        ),
        TipCard(
          icon: Icons.zoom_in,
          iconBg: Color(0xFFF3E5F5),
          iconColor: Colors.purple,
          title: "Capture Details",
          description:
              "Zoom in on important features, labels, and any defects. Transparency builds buyer trust.",
        ),
        TipCard(
          icon: Icons.straighten,
          iconBg: Color(0xFFFFF8E1),
          iconColor: Colors.amber,
          title: "Keep It Steady",
          description:
              "Use a tripod or rest your phone on a stable surface. Blurry photos reduce buyer confidence.",
        ),
        TipCard(
          icon: Icons.aspect_ratio,
          iconBg: Color(0xFFE0F2F1),
          iconColor: Colors.teal,
          title: "Right Dimensions",
          description:
              "Use square (1:1) or 4:3 ratio photos. Consistent sizing looks professional in listings.",
        ),
        TipCard(
          icon: Icons.image_outlined,
          iconBg: Color(0xFFFCE4EC),
          iconColor: Colors.pink,
          title: "Minimal Editing",
          description:
              "Adjust brightness if needed, but avoid heavy filters. Photos should represent the actual item.",
        ),
        TipCard(
          icon: Icons.phone_android,
          iconBg: Color(0xFFE8EAF6),
          iconColor: Colors.indigo,
          title: "Clean Your Lens",
          description:
              "Wipe your phone camera lens before shooting. Smudges cause blurry and hazy photos.",
        ),
      ],
    );
  }
}
