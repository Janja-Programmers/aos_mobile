import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/core.dart';

class ImageSearchSheet extends StatefulWidget {
  const ImageSearchSheet({super.key});

  @override
  State<ImageSearchSheet> createState() => _ImageSearchSheetState();
}

class _ImageSearchSheetState extends State<ImageSearchSheet> {
  File? _file;
  ImageSource? _selectedSource;

  bool get _hasPickedImage => _file != null;

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: source, imageQuality: 85);

    if (picked == null) return;

    setState(() {
      _file = File(picked.path);
      _selectedSource = source;
    });
  }

  void _submit() {
    final file = _file;
    if (file == null) return;

    Navigator.pop(context, file);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 26),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.textPrimary),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Image Search",
                      style: context.h4.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 24),

            _ImageOptionTile(
              icon: Icons.camera_alt_outlined,
              title: "Take a Photo",
              subtitle: _selectedSource == ImageSource.camera
                  ? "Photo selected. Ready to search"
                  : "Use your camera to capture\nan item",
              selected: _selectedSource == ImageSource.camera,
              onTap: () => _pick(ImageSource.camera),
            ),

            const SizedBox(height: 16),

            _ImageOptionTile(
              icon: Icons.photo_library_outlined,
              title: "Choose from Gallery",
              subtitle: _selectedSource == ImageSource.gallery
                  ? "Image selected. Ready to search"
                  : "Select an existing photo\nfrom your device",
              selected: _selectedSource == ImageSource.gallery,
              onTap: () => _pick(ImageSource.gallery),
            ),

            if (_hasPickedImage) ...[
              const SizedBox(height: 18),
              _SelectedImagePreview(file: _file!),
            ],

            const SizedBox(height: 34),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.primary.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡  Tips for better results",
                    style: context.pStrong.copyWith(color: colors.primary),
                  ),
                  const SizedBox(height: 14),
                  const _Tip("Use good lighting"),
                  const _Tip("Center the item in frame"),
                  const _Tip("Avoid blurry images"),
                  const _Tip("Show the full product"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasPickedImage ? _submit : null,
                    child: Text(
                      _hasPickedImage ? "Search" : "Pick Image",
                      style: AppTextStylesX(context).button,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageOptionTile extends StatelessWidget {
  const _ImageOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withOpacity(0.06) : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(selected ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.pStrong),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: context.small.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? colors.primary : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(file, width: 52, height: 52, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Image selected",
              style: context.pStrong.copyWith(color: colors.textPrimary),
            ),
          ),
          Icon(Icons.check_circle, color: colors.primary),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text("✅  $text", style: context.p),
    );
  }
}
