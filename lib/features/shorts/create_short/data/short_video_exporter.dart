import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

class ShortExportCancelled implements Exception {
  const ShortExportCancelled();
}

abstract interface class ShortVideoExporter {
  Future<String> export(
    ShortEditorState state, {
    void Function(double progress)? onProgress,
  });
  Future<void> cancel();
}

class ProShortVideoExporter implements ShortVideoExporter {
  String? _activeRenderId;

  @override
  Future<String> export(
    ShortEditorState state, {
    void Function(double progress)? onProgress,
  }) async {
    final source = File(state.sourcePath);
    if (!source.existsSync()) {
      throw const FileSystemException('The source video is missing.');
    }
    if (state.selectedDuration <= Duration.zero) {
      throw const FormatException('The selected video range is invalid.');
    }

    final support = await getApplicationSupportDirectory();
    final exportDirectory = Directory(
      '${support.path}${Platform.pathSeparator}shorts_exports',
    );
    await exportDirectory.create(recursive: true);
    final outputPath =
        '${exportDirectory.path}${Platform.pathSeparator}${state.sessionId}.mp4';
    final output = File(outputPath);
    if (output.existsSync()) {
      await output.delete();
    }

    final imageLayers = <ImageLayer>[];
    if (state.overlays.isNotEmpty) {
      final bytes = await _renderOverlayCanvas(
        overlays: state.overlays,
        videoSize: state.videoSize,
      );
      imageLayers.add(
        ImageLayer(
          image: EditorLayerImage.memory(bytes),
          offset: Offset.zero,
          size: state.videoSize,
        ),
      );
    }

    final renderData = VideoRenderData(
      videoSegments: <VideoSegment>[
        VideoSegment(
          video: EditorVideo.file(source),
          startTime: state.trimStart,
          endTime: state.trimEnd,
        ),
      ],
      imageLayers: imageLayers,
      shouldOptimizeForNetworkUse: true,
    );
    _activeRenderId = renderData.id;

    StreamSubscription<ProgressModel>? progressSubscription;
    if (onProgress != null) {
      progressSubscription = ProVideoEditor.instance
          .progressStreamById(renderData.id)
          .listen(
            (ProgressModel value) =>
                onProgress(value.progress.clamp(0, 1).toDouble()),
          );
    }

    try {
      try {
        await ProVideoEditor.instance.renderVideoToFile(outputPath, renderData);
      } on RenderCanceledException {
        throw const ShortExportCancelled();
      }
      onProgress?.call(1);
      return outputPath;
    } finally {
      _activeRenderId = null;
      await progressSubscription?.cancel();
    }
  }

  @override
  Future<void> cancel() async {
    final id = _activeRenderId;
    if (id == null || id.isEmpty) return;
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;
    await ProVideoEditor.instance.cancel(id);
  }
}

Future<Uint8List> _renderOverlayCanvas({
  required List<ShortOverlay> overlays,
  required Size videoSize,
}) async {
  if (videoSize.isEmpty) {
    throw const FormatException('Video dimensions are unavailable.');
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  for (final overlay in overlays) {
    final center = Offset(
      overlay.normalizedPosition.dx * videoSize.width,
      overlay.normalizedPosition.dy * videoSize.height,
    );
    final fontSize =
        switch (overlay.kind) {
          ShortOverlayKind.sticker => videoSize.shortestSide * .16,
          ShortOverlayKind.caption => videoSize.shortestSide * .055,
          ShortOverlayKind.text => videoSize.shortestSide * .07,
        } *
        overlay.scale;

    final painter = TextPainter(
      text: TextSpan(
        text: overlay.content,
        style: TextStyle(
          color: Color(overlay.colorValue),
          fontSize: fontSize,
          fontWeight: overlay.kind == ShortOverlayKind.sticker
              ? FontWeight.normal
              : FontWeight.w700,
          shadows: overlay.kind == ShortOverlayKind.sticker
              ? const <Shadow>[]
              : const <Shadow>[
                  Shadow(
                    color: Color(0xAA000000),
                    offset: Offset(1, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
      ),
      maxLines: overlay.kind == ShortOverlayKind.caption ? 3 : 6,
      textAlign: TextAlign.center,
      textDirection: _textDirectionFor(overlay.content),
    )..layout(maxWidth: videoSize.width * .86);

    final maxX = (videoSize.width - painter.width).clamp(0, videoSize.width);
    final maxY = (videoSize.height - painter.height).clamp(0, videoSize.height);
    final origin = Offset(
      (center.dx - painter.width / 2).clamp(0, maxX).toDouble(),
      (center.dy - painter.height / 2).clamp(0, maxY).toDouble(),
    );
    if (overlay.kind == ShortOverlayKind.caption) {
      final background = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx - 18,
          origin.dy - 10,
          painter.width + 36,
          painter.height + 20,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(background, Paint()..color = const Color(0xB3000000));
    }
    painter.paint(canvas, origin);
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    videoSize.width.round().clamp(1, 4096).toInt(),
    videoSize.height.round().clamp(1, 4096).toInt(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (data == null) throw StateError('Could not render video overlays.');
  return data.buffer.asUint8List();
}

TextDirection _textDirectionFor(String text) {
  final rtl = RegExp('[֐-ࣿ]');
  return rtl.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
}
