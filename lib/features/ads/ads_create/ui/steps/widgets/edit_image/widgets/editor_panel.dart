import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/edit_image/widgets/tool_button.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/edit_image/widgets/background_picker.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/edit_image/widgets/gradient_picker.dart';

class EditorPanel extends StatelessWidget {
  const EditorPanel({
    super.key,
    required this.onCrop,
    required this.onRotate,
    required this.onRemoveBg,
    required this.onBackgroundColor,
    required this.onGradient,
    required this.bgRemoved,
    required this.busy,
  });

  final VoidCallback onCrop;
  final VoidCallback onRotate;
  final VoidCallback onRemoveBg;

  final Function(Color?) onBackgroundColor;
  final Function(List<Color>) onGradient;

  final bool bgRemoved;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTools(),

          const SizedBox(height: 16),

          if (bgRemoved) BackgroundPicker(onSelect: onBackgroundColor),

          if (bgRemoved) const SizedBox(height: 16),

          if (bgRemoved) GradientPicker(onSelect: onGradient),
        ],
      ),
    );
  }

  Widget _buildTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ToolButton(
          icon: Icons.crop,
          label: "Crop",
          onTap: busy ? () {} : onCrop,
        ),

        ToolButton(
          icon: Icons.rotate_right,
          label: "Rotate",
          onTap: busy ? () {} : onRotate,
        ),

        ToolButton(
          icon: Icons.auto_fix_high,
          label: "Remove BG",
          active: bgRemoved,
          onTap: busy ? () {} : onRemoveBg,
        ),
      ],
    );
  }
}
