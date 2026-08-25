import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageSearchSheet extends ConsumerStatefulWidget {
  const ImageSearchSheet({super.key});

  @override
  ConsumerState<ImageSearchSheet> createState() => _ImageSearchSheetState();
}

class _ImageSearchSheetState extends ConsumerState<ImageSearchSheet> {
  AcquiredMedia? _media;
  MediaAcquisitionSource? _selectedSource;
  bool _transferred = false;
  bool _picking = false;

  bool get _hasPickedImage => _media != null;

  Future<void> _pick(MediaAcquisitionSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final acquisition = ref.read(mediaAcquisitionServiceProvider);
      final picked = source == MediaAcquisitionSource.camera
          ? await acquisition.captureImage(
              context,
              useCase: MediaUseCase.searchImage,
            )
          : await acquisition.pickImage(useCase: MediaUseCase.searchImage);
      if (picked == null) return;
      if (!mounted) {
        await picked.discard();
        return;
      }
      final previous = _media;
      setState(() {
        _media = picked;
        _selectedSource = source;
      });
      await previous?.discard();
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    final media = _media;
    if (media == null) return;

    _transferred = true;
    Navigator.pop(context, media);
  }

  @override
  void dispose() {
    if (!_transferred) unawaited(_media?.discard());
    super.dispose();
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
                      'Image Search',
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
              title: 'Take a Photo',
              subtitle: _selectedSource == MediaAcquisitionSource.camera
                  ? 'Photo selected. Ready to search'
                  : 'Use your camera to capture\nan item',
              selected: _selectedSource == MediaAcquisitionSource.camera,
              onTap: () => _pick(MediaAcquisitionSource.camera),
            ),

            const SizedBox(height: 16),

            _ImageOptionTile(
              icon: Icons.photo_library_outlined,
              title: 'Choose from Gallery',
              subtitle: _selectedSource == MediaAcquisitionSource.gallery
                  ? 'Image selected. Ready to search'
                  : 'Select an existing photo\nfrom your device',
              selected: _selectedSource == MediaAcquisitionSource.gallery,
              onTap: () => _pick(MediaAcquisitionSource.gallery),
            ),

            if (_hasPickedImage) ...[
              const SizedBox(height: 18),
              _SelectedImagePreview(media: _media!),
            ],

            const SizedBox(height: 34),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡  Tips for better results',
                    style: context.pStrong.copyWith(color: colors.primary),
                  ),
                  const SizedBox(height: 14),
                  const _Tip('Use good lighting'),
                  const _Tip('Center the item in frame'),
                  const _Tip('Avoid blurry images'),
                  const _Tip('Show the full product'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasPickedImage && !_picking ? _submit : null,
                    child: Text(
                      _hasPickedImage ? 'Search' : 'Pick Image',
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
          color: selected
              ? colors.primary.withValues(alpha: 0.06)
              : colors.surface,
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
                color: colors.primary.withValues(alpha: selected ? 0.14 : 0.08),
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
  const _SelectedImagePreview({required this.media});

  final AcquiredMedia media;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              media.file,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              cacheWidth: 208,
              cacheHeight: 208,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Image selected',
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
      child: Text('✅  $text', style: context.p),
    );
  }
}
