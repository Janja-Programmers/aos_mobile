import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/gradient_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/tool_button.dart';
import 'package:flutter/material.dart';

enum EditorToolAction { crop, rotate, removeBg }

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
    required this.selectedBackgroundColor,
    required this.selectedGradient,
    required this.transparentSelected,
    required this.applyingBackground,
    required this.activeTool,
  });

  final VoidCallback onCrop;
  final VoidCallback onRotate;
  final Future<void> Function() onRemoveBg;

  final ValueChanged<Color?> onBackgroundColor;
  final ValueChanged<List<Color>> onGradient;

  final bool bgRemoved;
  final bool busy;
  final bool applyingBackground;
  final bool transparentSelected;

  final Color? selectedBackgroundColor;
  final List<Color>? selectedGradient;

  final EditorToolAction? activeTool;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, -4),
            color: colors.border,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 18),
          _buildTools(context),
          if (bgRemoved) ...[
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 18),
            BackgroundPicker(
              selectedColor: selectedBackgroundColor,
              transparentSelected: transparentSelected,
              isApplying: applyingBackground,
              onSelect: onBackgroundColor,
            ),
            const SizedBox(height: 18),
            GradientPicker(
              selectedGradient: selectedGradient,
              isApplying: applyingBackground,
              onSelect: onGradient,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTools(BuildContext context) {
    final toolBusy = activeTool != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ToolButton(
          icon: Icons.crop_rounded,
          label: 'Crop',
          loading: activeTool == EditorToolAction.crop,
          disabled: toolBusy && activeTool != EditorToolAction.crop,
          onTap: busy ? null : onCrop,
        ),
        ToolButton(
          icon: Icons.rotate_right_rounded,
          label: 'Rotate',
          loading: activeTool == EditorToolAction.rotate,
          disabled: toolBusy && activeTool != EditorToolAction.rotate,
          onTap: busy ? null : onRotate,
        ),
        ToolButton(
          icon: Icons.auto_fix_high_rounded,
          label: bgRemoved ? 'BG Removed' : 'Remove BG',
          active: bgRemoved,
          loading: activeTool == EditorToolAction.removeBg,
          disabled: toolBusy && activeTool != EditorToolAction.removeBg,
          onTap: busy ? null : onRemoveBg,
        ),
      ],
    );
  }
}
