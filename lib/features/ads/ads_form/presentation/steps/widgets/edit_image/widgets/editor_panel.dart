// ignore: unused_import
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/tool_button.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/gradient_picker.dart';

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
  final Future<void> Function() onRemoveBg;

  final Function(Color?) onBackgroundColor;
  final Function(List<Color>) onGradient;

  final bool bgRemoved;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTools(context),
          const SizedBox(height: 16),
          if (bgRemoved) BackgroundPicker(onSelect: onBackgroundColor),
          if (bgRemoved) const SizedBox(height: 16),
          if (bgRemoved) GradientPicker(onSelect: onGradient),
        ],
      ),
    );
  }

  Widget _buildTools(BuildContext context) {
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
          onTap: busy ? () {} : () => onRemoveBg(),
        ),
      ],
    );
  }
}
