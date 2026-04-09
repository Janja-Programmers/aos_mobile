import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/shorts/application/widgets/post_short/ptimary_short_button.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/caption_input.dart';

class PostShortBottomPanel extends StatelessWidget {
  final TextEditingController captionController;
  final String? selectedAdId;

  final VoidCallback onChanged;
  final Function(List<String>) onHashtagsChanged;
  final VoidCallback onSelectAd;

  const PostShortBottomPanel({
    super.key,
    required this.captionController,
    required this.selectedAdId,
    required this.onChanged,
    required this.onHashtagsChanged,
    required this.onSelectAd,
  });

  @override
  Widget build(BuildContext context) {
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
                controller: captionController,
                onChanged: onChanged,
                onHashtagsChanged: onHashtagsChanged,
              ),

              const SizedBox(height: 12),

              PrimaryShortButton(
                label: selectedAdId == null ? "Select Ad" : "Ad Selected",
                onTap: onSelectAd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
