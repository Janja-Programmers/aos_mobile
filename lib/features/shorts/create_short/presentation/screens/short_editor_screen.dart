import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_editor_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/short_creation_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/short_trim_screen.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/short_sound_controls_sheet.dart';
import 'package:africaonlinestores/features/shorts/music/presentation/music_picker_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ShortEditorScreen extends ConsumerStatefulWidget {
  const ShortEditorScreen({super.key, required this.seed});

  final ShortEditorSeed seed;

  @override
  ConsumerState<ShortEditorScreen> createState() => _ShortEditorScreenState();
}

class _ShortEditorScreenState extends ConsumerState<ShortEditorScreen> {
  String? _draggingId;
  bool _overDelete = false;
  double _gestureStartScale = 1;
  Offset _gestureStartPosition = Offset.zero;
  late final Future<List<Uint8List>> _timeline;

  ShortEditorController get _controller =>
      ref.read(shortEditorControllerProvider(widget.seed).notifier);

  @override
  void initState() {
    super.initState();
    _timeline = _buildTimeline(widget.seed.sourcePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_controller.initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortEditorControllerProvider(widget.seed));
    final player = _controller.player;

    ref.listen<ShortEditorState>(shortEditorControllerProvider(widget.seed), (
      previous,
      next,
    ) {
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return PopScope(
      canPop: !state.hasUnsavedChanges && !state.isExporting,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _showExitOptions();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0E12),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _appBar(state),
              Expanded(
                child: state.errorMessage != null && !state.isInitialized
                    ? _fatalError(state.errorMessage!)
                    : !state.isInitialized || player == null
                    ? const Center(child: CircularProgressIndicator())
                    : _videoCanvas(state, player),
              ),
              _timelineStrip(),
              _editorActions(state),
            ],
          ),
        ),
        bottomSheet: state.isExporting ? _exportProgress(state) : null,
      ),
    );
  }

  Widget _appBar(ShortEditorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: <Widget>[
          IconButton.filled(
            tooltip: 'Discard recording',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x88000000),
              foregroundColor: Colors.white,
            ),
            onPressed: state.isExporting ? null : _confirmDiscardRecording,
            icon: const Icon(Icons.close_rounded),
          ),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0x88000000),
                foregroundColor: Colors.white,
              ),
              onPressed: state.isExporting ? null : _pickSound,
              icon: const Icon(Icons.music_note_rounded),
              label: Text(
                state.selectedSound.isOriginal
                    ? 'Add sound'
                    : state.selectedSound.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStylesX(context).button,
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: state.isInitialized && !state.isExporting ? _next : null,
            iconAlignment: IconAlignment.end,
            label: Text('Next', style: AppTextStylesX(context).button),
          ),
        ],
      ),
    );
  }

  Widget _videoCanvas(ShortEditorState state, VideoPlayerController player) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspect = player.value.aspectRatio <= 0
            ? 9 / 16
            : player.value.aspectRatio;
        final available = Size(constraints.maxWidth, constraints.maxHeight);
        final canvasSize = _containedSize(available, aspect);
        return Center(
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                GestureDetector(
                  onTap: _controller.togglePlayback,
                  child: VideoPlayer(player),
                ),
                ...state.overlays.map(
                  (overlay) => _overlayWidget(overlay, canvasSize),
                ),
                if (_draggingId != null)
                  Positioned(
                    left: canvasSize.width / 2 - 34,
                    bottom: 18,
                    child: Semantics(
                      liveRegion: true,
                      label: _overDelete
                          ? 'Release to delete overlay'
                          : 'Drag overlay here to delete',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: _overDelete ? Colors.red : Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: player,
                  builder: (context, value, _) {
                    if (value.isPlaying) return const SizedBox.shrink();
                    return Center(
                      child: IconButton.filled(
                        tooltip: 'Play preview',
                        onPressed: _controller.togglePlayback,
                        iconSize: 38,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _overlayWidget(ShortOverlay overlay, Size canvasSize) {
    final left = overlay.normalizedPosition.dx * canvasSize.width;
    final top = overlay.normalizedPosition.dy * canvasSize.height;
    final style = TextStyle(
      color: Color(overlay.colorValue),
      fontWeight: overlay.kind == ShortOverlayKind.sticker
          ? FontWeight.normal
          : FontWeight.w800,
      fontSize: switch (overlay.kind) {
        ShortOverlayKind.sticker => 48,
        ShortOverlayKind.caption => 22,
        ShortOverlayKind.text => 30,
      },
      shadows: overlay.kind == ShortOverlayKind.sticker
          ? null
          : const <Shadow>[
              Shadow(
                color: Colors.black87,
                blurRadius: 5,
                offset: Offset(1, 2),
              ),
            ],
    );
    return Positioned(
      left: left - 110,
      top: top - 50,
      width: 220,
      height: 100,
      child: Semantics(
        button: true,
        label: '${overlay.kind.name} overlay: ${overlay.content}',
        hint: 'Drag to move. Pinch to resize.',
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (_) {
            setState(() {
              _draggingId = overlay.id;
              _gestureStartScale = overlay.scale;
              _gestureStartPosition = overlay.normalizedPosition;
              _overDelete = false;
            });
          },
          onScaleUpdate: (details) {
            final next = Offset(
              _gestureStartPosition.dx +
                  details.focalPointDelta.dx / canvasSize.width,
              _gestureStartPosition.dy +
                  details.focalPointDelta.dy / canvasSize.height,
            );
            _gestureStartPosition = next;
            final inDelete = next.dy > .78 && (next.dx - .5).abs() < .18;
            if (_overDelete != inDelete) setState(() => _overDelete = inDelete);
            _controller.updateOverlay(
              overlay.id,
              normalizedPosition: next,
              scale: (_gestureStartScale * details.scale)
                  .clamp(.5, 3)
                  .toDouble(),
            );
          },
          onScaleEnd: (_) {
            if (_overDelete) _controller.deleteOverlay(overlay.id);
            setState(() {
              _draggingId = null;
              _overDelete = false;
            });
          },
          onDoubleTap: overlay.kind == ShortOverlayKind.caption
              ? _editCaption
              : overlay.kind == ShortOverlayKind.text
              ? () => _editExistingText(overlay)
              : null,
          child: Center(
            child: Transform.scale(
              scale: overlay.scale,
              child: Container(
                padding: overlay.kind == ShortOverlayKind.caption
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                    : EdgeInsets.zero,
                decoration: overlay.kind == ShortOverlayKind.caption
                    ? BoxDecoration(
                        color: Colors.black.withValues(alpha: .7),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  overlay.content,
                  textAlign: TextAlign.center,
                  maxLines: overlay.kind == ShortOverlayKind.caption ? 3 : 5,
                  overflow: TextOverflow.visible,
                  style: style,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timelineStrip() {
    final AppImageDecodeSize decodeSize = AppImageDecode.forBox(
      context,
      logicalHeight: 70,
    );
    return Container(
      height: 86,
      color: const Color(0xFF111217),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: FutureBuilder<List<Uint8List>>(
        future: _timeline,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Uint8List>[];
          if (snapshot.hasError) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white54,
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LinearProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(
              child: Icon(Icons.video_file_outlined, color: Colors.white54),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: items
                  .map(
                    (bytes) => Expanded(
                      child: Image.memory(
                        bytes,
                        height: 70,
                        fit: BoxFit.cover,
                        cacheWidth: decodeSize.width,
                        cacheHeight: decodeSize.height,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        },
      ),
    );
  }

  Widget _editorActions(ShortEditorState state) {
    final items = <({IconData icon, String label, VoidCallback action})>[
      (icon: Icons.content_cut_rounded, label: 'Trim', action: _openTrim),
      (icon: Icons.music_note_rounded, label: 'Sound', action: _pickSound),
      if (!state.selectedSound.isOriginal)
        (
          icon: Icons.tune_rounded,
          label: 'Edit sound',
          action: _editSoundControls,
        ),
      (icon: Icons.text_fields_rounded, label: 'Text', action: _addText),
      (
        icon: Icons.emoji_emotions_outlined,
        label: 'Stickers',
        action: _addSticker,
      ),
      (
        icon: Icons.closed_caption_outlined,
        label: 'Captions',
        action: _editCaption,
      ),
    ];
    return Container(
      color: const Color(0xFF0D0E12),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map((item) {
                return SizedBox(
                  width: 104,
                  child: Column(
                    children: <Widget>[
                      IconButton.filled(
                        tooltip: item.label,
                        onPressed: state.isExporting ? null : item.action,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(58, 58),
                          backgroundColor: const Color(0xFF232429),
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(item.icon, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  Widget _fatalError(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Colors.white, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _controller.initialize,
              child: Text('Retry', style: AppTextStylesX(context).button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportProgress(ShortEditorState state) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF17181D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Preparing your short',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: state.exportProgress),
            const SizedBox(height: 8),
            Text(
              '${(state.exportProgress * 100).round()}%',
              style: const TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => unawaited(_controller.cancelExport()),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTrim() async {
    final state = ref.read(shortEditorControllerProvider(widget.seed));
    final result = await Navigator.of(context).push<ShortTrimSelection>(
      MaterialPageRoute<ShortTrimSelection>(
        builder: (_) => ShortTrimScreen(
          sourcePath: state.sourcePath,
          duration: state.duration,
          initialStart: state.trimStart,
          initialEnd: state.trimEnd,
        ),
      ),
    );
    if (result != null) await _controller.setTrim(result.start, result.end);
  }

  Future<void> _pickSound() async {
    final selected = await showMusicPickerSheet(context);
    if (selected != null) _controller.setSound(selected);
  }

  Future<void> _editSoundControls() async {
    final state = ref.read(shortEditorControllerProvider(widget.seed));
    if (state.selectedSound.isOriginal) {
      await _pickSound();
      return;
    }
    final result = await showShortSoundControlsSheet(
      context,
      sound: state.selectedSound,
      clipDuration: state.selectedDuration,
    );
    if (result != null) _controller.setSound(result);
  }

  Future<void> _addText() async {
    final result = await _showTextComposer();
    if (result != null) {
      _controller.addText(text: result.$1, colorValue: result.$2);
    }
  }

  Future<void> _editExistingText(ShortOverlay overlay) async {
    final result = await _showTextComposer(
      initialText: overlay.content,
      initialColor: overlay.colorValue,
    );
    if (result != null) {
      _controller.updateOverlay(
        overlay.id,
        content: result.$1,
        colorValue: result.$2,
      );
    }
  }

  Future<(String, int)?> _showTextComposer({
    String initialText = '',
    int initialColor = 0xFFFFFFFF,
  }) async {
    final text = TextEditingController(text: initialText);
    var color = initialColor;
    final result = await showModalBottomSheet<(String, int)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xEE101116),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final colors = <int>[
            0xFFFFFFFF,
            0xFF000000,
            0xFFD11222,
            0xFFFFB515,
            0xFF48B557,
            0xFF269CE8,
            0xFFE91E63,
            0xFF9C27B0,
          ];
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        final clean = text.text.trim();
                        if (clean.isNotEmpty) {
                          Navigator.pop(context, (clean, color));
                        }
                      },
                      child: Text(
                        'Done',
                        style: AppTextStylesX(context).button,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: text,
                  autofocus: true,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(color),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type something…',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: colors
                        .map((value) {
                          return GestureDetector(
                            onTap: () => setSheetState(() => color = value),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(value),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color == value
                                      ? Colors.red
                                      : Colors.white,
                                  width: color == value ? 4 : 2,
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    text.dispose();
    return result;
  }

  Future<void> _addSticker() async {
    const stickers = <String>[
      '😀',
      '😍',
      '🔥',
      '🎉',
      '❤️',
      '👍',
      '😎',
      '🥳',
      '✨',
      '💯',
      '🚀',
      '⭐',
      '😂',
      '🙌',
      '👀',
      '💪',
      '🎶',
      '☀️',
      '🌈',
      '⚡',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: stickers
              .map((sticker) {
                return Semantics(
                  button: true,
                  label: 'Add $sticker sticker',
                  child: InkWell(
                    onTap: () => Navigator.pop(context, sticker),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Text(
                        sticker,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
    if (selected != null) _controller.addSticker(selected);
  }

  Future<void> _editCaption() async {
    final state = ref.read(shortEditorControllerProvider(widget.seed));
    ShortOverlay? existing;
    for (final item in state.overlays) {
      if (item.kind == ShortOverlayKind.caption) {
        existing = item;
        break;
      }
    }
    final text = TextEditingController(text: existing?.content ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: text,
              autofocus: true,
              maxLength: 180,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'On-video caption',
                hintText: 'Add caption text',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (existing != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Remove'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context, text.text.trim()),
                  child: Text('Done', style: AppTextStylesX(context).button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    text.dispose();
    if (result != null) _controller.setCaption(result);
  }

  Future<void> _next() async {
    try {
      await _controller.saveDraft();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The edit could not be saved before publishing.'),
        ),
      );
      return;
    }

    final output = await _controller.export();
    if (output == null || !mounted) return;
    final state = ref.read(shortEditorControllerProvider(widget.seed));
    final durationSeconds =
        state.selectedDuration.inMilliseconds / Duration.millisecondsPerSecond;
    ShortsNavigation.toPostShortDetails(
      context,
      sessionId: state.sessionId,
      media: <SelectedMedia>[
        SelectedMedia(
          File(output),
          MediaType.video,
          durationSeconds: durationSeconds,
        ),
      ],
      selectedSound: state.selectedSound,
    );
  }

  Future<void> _confirmDiscardRecording() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this recording?'),
        content: const Text('This recording will be removed.'),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: AppTextStylesX(context).button),
          ),
        ],
      ),
    );
    if (discard != true) return;
    await _controller.discard();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showExitOptions() async {
    final state = ref.read(shortEditorControllerProvider(widget.seed));
    if (!state.hasUnsavedChanges) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final action = await showModalBottomSheet<_ExitAction>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Save draft'),
              onTap: () => Navigator.pop(context, _ExitAction.saveDraft),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Discard', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, _ExitAction.discard),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _ExitAction.cancel),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case _ExitAction.saveDraft:
        try {
          await _controller.saveDraft();
          if (mounted) Navigator.pop(context);
          return;
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Draft could not be saved.')),
            );
          }
          return;
        }
      case _ExitAction.discard:
        await _controller.discard();
        if (mounted) Navigator.pop(context);
        return;
      case _ExitAction.cancel:
      case null:
        return;
    }
  }

  Future<List<Uint8List>> _buildTimeline(String path) async {
    const count = 8;
    final results = <Uint8List>[];
    for (var index = 0; index < count; index++) {
      final bytes = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
        maxHeight: 320,
        timeMs: index * 1000,
      );
      if (bytes != null) results.add(bytes);
    }
    return results;
  }

  Size _containedSize(Size available, double aspect) {
    if (available.width <= 0 || available.height <= 0 || aspect <= 0) {
      return Size.zero;
    }
    final availableAspect = available.width / available.height;
    if (availableAspect > aspect) {
      final height = available.height;
      return Size(height * aspect, height);
    }
    final width = available.width;
    return Size(width, width / aspect);
  }
}

enum _ExitAction { saveDraft, discard, cancel }
