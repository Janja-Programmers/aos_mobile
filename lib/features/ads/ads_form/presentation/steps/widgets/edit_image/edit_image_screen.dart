import 'dart:io';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/utils/url_to_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/editor_panel.dart';

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
    setState(() => _busy = true);

    try {
      final controller = ref.read(adDraftControllerProvider.notifier);

      final res = await controller.removeImageBackground(widget.index);

      if (res.isLeft) {
        debugPrint(res.leftOrNull!.message);
        return;
      }

      final url = res.rightOrNull!;

      final file = await urlToFile(url);

      _tempFiles.add(file);

      setState(() {
        _transparentFile = file;
        _file = file;
        _bgRemoved = true;
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  // ================= APPLY BACKGROUND =================

  Future<void> _applyBackground(Color? color) async {
    if (_transparentFile == null) return;

    final bytes = await _transparentFile!.readAsBytes();
    final foreground = img.decodeImage(bytes);

    if (foreground == null) return;

    final dir = await getTemporaryDirectory();

    final path = "${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.png";

    File file;

    if (color == null) {
      file = File(path)..writeAsBytesSync(img.encodePng(foreground));
    } else {
      final background = img.Image(
        width: foreground.width,
        height: foreground.height,
      );

      img.fill(
        background,
        color: img.ColorRgb8(color.red, color.green, color.blue),
      );

      img.compositeImage(background, foreground);

      file = File(path)..writeAsBytesSync(img.encodePng(background));
    }

    _tempFiles.add(file);

    setState(() {
      _file = file;
      _selectedBgColor = color;
    });
  }

  // ================= APPLY GRADIENT =================

  Future<void> _applyGradient(List<Color> colors) async {
    if (_transparentFile == null) return;

    final bytes = await _transparentFile!.readAsBytes();
    final foreground = img.decodeImage(bytes);

    if (foreground == null) return;

    final dir = await getTemporaryDirectory();

    final path =
        "${dir.path}/gradient_${DateTime.now().millisecondsSinceEpoch}.png";

    final background = img.Image(
      width: foreground.width,
      height: foreground.height,
    );

    for (int y = 0; y < background.height; y++) {
      final ratio = y / background.height;

      final r = (colors[0].red * (1 - ratio) + colors[1].red * ratio).toInt();
      final g = (colors[0].green * (1 - ratio) + colors[1].green * ratio)
          .toInt();
      final b = (colors[0].blue * (1 - ratio) + colors[1].blue * ratio).toInt();

      for (int x = 0; x < background.width; x++) {
        background.setPixelRgb(x, y, r, g, b);
      }
    }

    img.compositeImage(background, foreground);

    final file = File(path)..writeAsBytesSync(img.encodePng(background));

    _tempFiles.add(file);

    setState(() {
      _file = file;
      _selectedBgColor = colors.first;
    });
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
                  child: Image.file(
                    _file,
                    key: ValueKey(_file.path),
                    fit: BoxFit.contain,
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
