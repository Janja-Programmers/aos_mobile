import 'package:africaonlinestores/features/shorts/application/screens/post_short/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_controller.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/application/screens/post_short/ptimary_short_button.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/caption_input.dart';

class PostShortBottomPanel extends StatefulWidget {
  final PostShortController controller;
  final VoidCallback onChanged;
  final Function(List<String>) onHashtagsChanged;

  const PostShortBottomPanel({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onHashtagsChanged,
  });

  @override
  State<PostShortBottomPanel> createState() => _PostShortBottomPanelState();
}

class _PostShortBottomPanelState extends State<PostShortBottomPanel> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              CaptionInput(
                controller: controller.captionController,
                onChanged: widget.onChanged,
                onHashtagsChanged: widget.onHashtagsChanged,
              ),

              PrimaryShortButton(
                label: controller.selectedAdId == null
                    ? "Select Ad"
                    : "Ad Selected",
                onTap: _openAdPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAdPicker() {
    final controller = widget.controller;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) {
        return AdPickerBottomSheet(
          onSelected: (adId) {
            controller.setAd(adId, () {
              setState(() {});
            });
          },
        );
      },
    );
  }
}
