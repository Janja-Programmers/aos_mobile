import 'dart:io';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

const int goLiveTitleMaxLength = 140;

@immutable
class GoLiveDetailsDraft {
  const GoLiveDetailsDraft({required this.title, required this.coverImage});

  final String title;
  final File? coverImage;
}

class GoLiveDetailsSheet extends StatefulWidget {
  const GoLiveDetailsSheet({
    super.key,
    required this.initialTitle,
    required this.displayName,
    required this.coverImageUrl,
    required this.coverImage,
    required this.pickCover,
  });

  final String initialTitle;
  final String displayName;
  final String? coverImageUrl;
  final File? coverImage;
  final Future<File?> Function(BuildContext context) pickCover;

  @override
  State<GoLiveDetailsSheet> createState() => _GoLiveDetailsSheetState();
}

class _GoLiveDetailsSheetState extends State<GoLiveDetailsSheet> {
  late final TextEditingController _titleController;
  File? _coverImage;
  bool _isPickingCover = false;

  bool get _canSave =>
      !_isPickingCover && _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _coverImage = widget.coverImage;
  }

  Future<void> _changeCover() async {
    if (_isPickingCover) return;

    setState(() => _isPickingCover = true);
    try {
      final image = await widget.pickCover(context);
      if (!mounted || image == null) return;
      setState(() => _coverImage = image);
    } finally {
      if (mounted) setState(() => _isPickingCover = false);
    }
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(
      GoLiveDetailsDraft(
        title: _titleController.text.trim(),
        coverImage: _coverImage,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 42,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.liveDetailsTitle,
                        style: context.h3,
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: LiveCoverPreview(
                    key: const Key('go_live_details_cover_preview'),
                    width: 164,
                    height: 200,
                    imageFile: _coverImage,
                    imageUrl: widget.coverImageUrl,
                    displayName: widget.displayName,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    key: const Key('go_live_change_cover'),
                    onPressed: _isPickingCover ? null : _changeCover,
                    icon: _isPickingCover
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                    label: Text(context.l10n.liveChangeCoverAction),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('go_live_title_field'),
                  controller: _titleController,
                  maxLength: goLiveTitleMaxLength,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: context.l10n.liveTitleLabel,
                    hintText: context.l10n.liveTitleHint,
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('go_live_save_details'),
                        onPressed: _canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.btnText,
                        ),
                        child: Text(context.l10n.common_save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiveCoverPreview extends StatelessWidget {
  const LiveCoverPreview({
    super.key,
    required this.width,
    required this.height,
    required this.displayName,
    this.imageFile,
    this.imageUrl,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final double width;
  final double height;
  final String displayName;
  final File? imageFile;
  final String? imageUrl;
  final BorderRadius borderRadius;

  String get _initial {
    final clean = displayName.trim();
    return clean.isEmpty ? 'U' : clean.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cleanUrl = imageUrl?.trim() ?? '';

    final Widget image;
    if (imageFile != null) {
      image = Image.file(
        imageFile!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: (width * 3).round(),
        cacheHeight: (height * 3).round(),
        errorBuilder: (_, _, _) =>
            _CoverFallback(width: width, height: height, initial: _initial),
      );
    } else if (cleanUrl.isNotEmpty) {
      image = AppNetworkImage(url: cleanUrl, width: width, height: height);
    } else {
      image = _CoverFallback(width: width, height: height, initial: _initial);
    }

    return Semantics(
      image: true,
      label: context.l10n.liveCoverLabel,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.white.withValues(alpha: .14),
            border: Border.all(color: colors.white.withValues(alpha: .16)),
            borderRadius: borderRadius,
          ),
          child: SizedBox(width: width, height: height, child: image),
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({
    required this.width,
    required this.height,
    required this.initial,
  });

  final double width;
  final double height;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            initial,
            style: context.h2.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
