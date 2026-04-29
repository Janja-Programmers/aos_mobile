import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_removal_await_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_removal_confirm_dialog.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/editor_panel.dart';

import 'package:africaonlinestores/shared/utils/url_to_file.dart';

class EditImageScreen extends ConsumerStatefulWidget {
  const EditImageScreen({
    super.key,
    required this.file,
    required this.fileId,
    required this.index,
  });

  final File file;
  final String fileId;
  final int index;

  @override
  ConsumerState<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends ConsumerState<EditImageScreen> {
  late File _file;

  bool _busy = false;

  bool _bgRemoved = false;
  Color? _selectedBgColor;
  File? _transparentFile;
  bool _applyingBackground = false;

  final List<File> _tempFiles = [];

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  // ================= CROP =================

  Future<void> _crop() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: _file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop",
          toolbarColor: context.appColors.black,
          toolbarWidgetColor: context.appColors.white,

          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,

          hideBottomControls: false,

          showCropGrid: true,
          cropGridStrokeWidth: 2,

          activeControlsWidgetColor: context.appColors.red,
        ),

        IOSUiSettings(
          title: "Crop",
          aspectRatioLockEnabled: false,
          rotateButtonsHidden: false,
        ),
      ],
    );

    if (cropped == null) return;

    final file = File(cropped.path);

    _tempFiles.add(file);

    setState(() => _file = file);
  }
  // ================= ROTATE =================

  Future<void> _rotate() async {
    final bytes = await _file.readAsBytes();

    final image = img.decodeImage(bytes);
    if (image == null) return;

    final rotated = img.copyRotate(image, angle: 90);

    final dir = await getTemporaryDirectory();

    final path =
        "${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.png";

    final file = File(path)..writeAsBytesSync(img.encodePng(rotated));

    _tempFiles.add(file);

    setState(() => _file = file);
  }

  // ================= COMPRESS =================

  Future<void> _compress() async {
    if (_selectedBgColor == null) return;

    final dir = await getTemporaryDirectory();

    final target =
        "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      _file.path,
      target,
      quality: 80,
    );

    if (result != null) {
      final file = File(result.path);

      _tempFiles.add(file);

      setState(() => _file = file);
    }
  }

  // ================= REMOVE BG =================

  Future<void> _removeBg() async {
    final originalFile = _file;

    setState(() => _busy = true);

    final File? removedFile = await showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackgroundRemovalAwaitDialog(
        removeBg: () async {
          final controller = ref.read(adDraftControllerProvider.notifier);

          final res = await controller.removeImageBackground(widget.index);

          if (res.isLeft) {
            throw Exception(res.leftOrNull!.message);
          }

          final url = res.rightOrNull!;
          final file = await urlToFile(url);

          _tempFiles.add(file);

          return file;
        },
      ),
    );

    if (!mounted) return;

    setState(() => _busy = false);

    if (removedFile == null) {
      setState(() {
        _file = originalFile;
        _transparentFile = null;
        _bgRemoved = false;
        _selectedBgColor = null;
      });
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackgroundRemovalConfirmDialog(file: removedFile),
    );

    if (!mounted) return;

    if (accepted == true) {
      setState(() {
        _file = removedFile;
        _transparentFile = removedFile;
        _bgRemoved = true;
        _selectedBgColor = null;
      });
    } else {
      setState(() {
        _file = originalFile;
        _transparentFile = null;
        _bgRemoved = false;
        _selectedBgColor = null;
      });
    }
  }

  // ================= APPLY BACKGROUND =================

  Future<void> _applyBackground(Color? color) async {
    if (_transparentFile == null || _applyingBackground) return;

    setState(() => _applyingBackground = true);

    try {
      final dir = await getTemporaryDirectory();

      final outputPath =
          "${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.png";

      final resultPath = await compute(_applyBackgroundInIsolate, {
        'sourcePath': _transparentFile!.path,
        'outputPath': outputPath,
        'color': color?.value,
      });

      final file = File(resultPath);

      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
        _selectedBgColor = color;
      });
    } finally {
      if (mounted) {
        setState(() => _applyingBackground = false);
      }
    }
  }

  String _applyBackgroundInIsolate(Map<String, dynamic> args) {
    final sourcePath = args['sourcePath'] as String;
    final outputPath = args['outputPath'] as String;
    final colorValue = args['color'] as int?;

    final bytes = File(sourcePath).readAsBytesSync();
    final foreground = img.decodeImage(bytes);

    if (foreground == null) {
      throw Exception('Failed to decode image');
    }

    if (colorValue == null) {
      File(outputPath).writeAsBytesSync(img.encodePng(foreground));
      return outputPath;
    }

    final background = img.Image(
      width: foreground.width,
      height: foreground.height,
    );

    final r = (colorValue >> 16) & 0xff;
    final g = (colorValue >> 8) & 0xff;
    final b = colorValue & 0xff;

    img.fill(background, color: img.ColorRgb8(r, g, b));

    img.compositeImage(background, foreground);

    File(outputPath).writeAsBytesSync(img.encodePng(background));

    return outputPath;
  }

  // ================= APPLY GRADIENT =================

  Future<void> _applyGradient(List<Color> colors) async {
    if (_transparentFile == null || _applyingBackground) return;

    setState(() => _applyingBackground = true);

    try {
      final dir = await getTemporaryDirectory();

      final outputPath =
          "${dir.path}/gradient_${DateTime.now().millisecondsSinceEpoch}.png";

      final resultPath = await compute(_applyGradientInIsolate, {
        'sourcePath': _transparentFile!.path,
        'outputPath': outputPath,
        'startColor': colors[0].value,
        'endColor': colors[1].value,
      });

      final file = File(resultPath);

      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
        _selectedBgColor = colors.first;
      });
    } finally {
      if (mounted) {
        setState(() => _applyingBackground = false);
      }
    }
  }

  String _applyGradientInIsolate(Map<String, dynamic> args) {
    final sourcePath = args['sourcePath'] as String;
    final outputPath = args['outputPath'] as String;
    final startColor = args['startColor'] as int;
    final endColor = args['endColor'] as int;

    final bytes = File(sourcePath).readAsBytesSync();
    final foreground = img.decodeImage(bytes);

    if (foreground == null) {
      throw Exception('Failed to decode image');
    }

    final background = img.Image(
      width: foreground.width,
      height: foreground.height,
    );

    final r1 = (startColor >> 16) & 0xff;
    final g1 = (startColor >> 8) & 0xff;
    final b1 = startColor & 0xff;

    final r2 = (endColor >> 16) & 0xff;
    final g2 = (endColor >> 8) & 0xff;
    final b2 = endColor & 0xff;

    for (int y = 0; y < background.height; y++) {
      final ratio = y / background.height;

      final r = (r1 * (1 - ratio) + r2 * ratio).toInt();
      final g = (g1 * (1 - ratio) + g2 * ratio).toInt();
      final b = (b1 * (1 - ratio) + b2 * ratio).toInt();

      for (int x = 0; x < background.width; x++) {
        background.setPixelRgb(x, y, r, g, b);
      }
    }

    img.compositeImage(background, foreground);

    File(outputPath).writeAsBytesSync(img.encodePng(background));

    return outputPath;
  }

  // ================= DONE =================

  Future<void> _done() async {
    if (_busy) return;

    if (_bgRemoved && _selectedBgColor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a background")));
      return;
    }

    setState(() => _busy = true);

    try {
      await _compress();

      final controller = ref.read(adDraftControllerProvider.notifier);

      await controller.replaceImageAt(widget.index, _file);

      if (!mounted) return;

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  // ================= CLEANUP =================

  @override
  void dispose() {
    for (final file in _tempFiles) {
      try {
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    }
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Image"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            _busy
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(onPressed: _done, child: const Text("Done")),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        _file,
                        key: ValueKey(_file.path),
                        fit: BoxFit.contain,
                      ),
                      if (_applyingBackground)
                        const CircularProgressIndicator(strokeWidth: 2.5),
                    ],
                  ),
                ),
              ),
            ),

            EditorPanel(
              onCrop: _crop,
              onRotate: _rotate,
              onRemoveBg: _removeBg,
              onBackgroundColor: _applyBackground,
              onGradient: _applyGradient,
              bgRemoved: _bgRemoved,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}
