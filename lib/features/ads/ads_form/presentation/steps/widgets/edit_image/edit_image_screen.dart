import 'dart:io';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/utils/background_colors.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_removal_await_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/background_removal_confirm_dialog.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/editor_panel.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/utils/url_to_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _applyingBackground = false;
  bool _backgroundSelectionMade = false;

  EditorToolAction? _activeTool;

  Color? _selectedBgColor;
  List<Color>? _selectedGradient;

  File? _transparentFile;
  String? _returnedFilePath;

  final List<File> _tempFiles = [];

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  // ================= CROP =================

  Future<void> _crop() async {
    if (_activeTool != null || _busy) return;

    setState(() => _activeTool = EditorToolAction.crop);

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: _file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: context.appColors.black,
            toolbarWidgetColor: context.appColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            cropGridStrokeWidth: 2,
            activeControlsWidgetColor: context.appColors.red,
          ),
          IOSUiSettings(title: 'Crop'),
        ],
      );

      if (cropped == null) return;

      final file = File(cropped.path);
      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
        if (_bgRemoved) {
          _transparentFile = file;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _activeTool = null);
      }
    }
  }

  // ================= ROTATE =================

  Future<void> _rotate() async {
    if (_activeTool != null || _busy) return;

    setState(() => _activeTool = EditorToolAction.rotate);

    try {
      await Future<void>.delayed(Duration.zero);

      final bytes = await _file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return;

      final rotated = img.copyRotate(image, angle: 90);
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path)..writeAsBytesSync(img.encodePng(rotated));

      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
        if (_bgRemoved) {
          _transparentFile = file;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _activeTool = null);
      }
    }
  }

  // ================= REMOVE BG =================

  Future<void> _removeBg() async {
    if (_busy) return;

    final originalFile = _file;

    setState(() {
      _busy = true;
      _activeTool = EditorToolAction.removeBg;
    });

    final File? removedFile = await showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackgroundRemovalAwaitDialog(
        removeBg: () async {
          final controller = ref.read(adDraftControllerProvider.notifier);
          final res = await controller.requestImageBackgroundRemoval(
            widget.index,
          );

          if (res.isLeft) {
            throw Exception(res.leftOrNull!.message);
          }

          final generated = res.rightOrNull!;
          try {
            final file = await urlToFile(generated.url);
            _tempFiles.add(file);
            return file;
          } finally {
            // Background-removal output is only a temporary editing source.
            // The draft remains unchanged until the final edited image uploads.
            await controller.deleteMediaSilently(generated.fileId);
          }
        },
      ),
    );

    if (!mounted) return;

    setState(() {
      _busy = false;
      _activeTool = null;
    });

    if (removedFile == null) {
      setState(() {
        _file = originalFile;
        _transparentFile = null;
        _bgRemoved = false;
        _backgroundSelectionMade = false;
        _selectedBgColor = null;
        _selectedGradient = null;
      });
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackgroundRemovalConfirmDialog(file: removedFile),
    );

    if (!mounted) return;

    if (accepted ?? false) {
      setState(() {
        _file = removedFile;
        _transparentFile = removedFile;
        _bgRemoved = true;
        _backgroundSelectionMade = false;
        _selectedBgColor = null;
        _selectedGradient = null;
      });
    } else {
      setState(() {
        _file = originalFile;
        _transparentFile = null;
        _bgRemoved = false;
        _backgroundSelectionMade = false;
        _selectedBgColor = null;
        _selectedGradient = null;
      });
    }
  }

  // ================= BACKGROUND SELECTION =================

  void _applyBackground(Color? color) {
    if (_transparentFile == null || _busy) return;

    setState(() {
      _backgroundSelectionMade = true;
      _selectedBgColor = color;
      _selectedGradient = null;
    });
  }

  void _applyGradient(List<Color> colors) {
    if (_transparentFile == null || _busy || colors.length < 2) return;

    setState(() {
      _backgroundSelectionMade = true;
      _selectedGradient = List<Color>.unmodifiable(colors);
      _selectedBgColor = null;
    });
  }

  Future<void> _materializeBackground() async {
    final source = _transparentFile;
    if (!_bgRemoved || source == null || !_backgroundSelectionMade) return;

    final gradient = _selectedGradient;
    final color = _selectedBgColor;

    // Transparent is a valid explicit selection and requires no re-encoding.
    if (gradient == null && color == null) {
      _file = source;
      return;
    }

    setState(() => _applyingBackground = true);

    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().microsecondsSinceEpoch;

      final String resultPath;
      if (gradient != null) {
        final outputPath = '${dir.path}/gradient_$timestamp.png';
        resultPath = await compute(applyGradientInIsolate, {
          'sourcePath': source.path,
          'outputPath': outputPath,
          'startColor': gradient[0].toARGB32(),
          'endColor': gradient[1].toARGB32(),
        });
      } else {
        final outputPath = '${dir.path}/bg_$timestamp.png';
        resultPath = await compute(applyBackgroundInIsolate, {
          'sourcePath': source.path,
          'outputPath': outputPath,
          'color': color!.toARGB32(),
        });
      }

      final file = File(resultPath);
      _tempFiles.add(file);

      if (!mounted) return;
      setState(() => _file = file);
    } finally {
      if (mounted) {
        setState(() => _applyingBackground = false);
      }
    }
  }

  // ================= DONE =================

  Future<void> _done() async {
    if (_busy) return;

    if (_bgRemoved && !_backgroundSelectionMade) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a background')));
      return;
    }

    setState(() => _busy = true);

    try {
      await _materializeBackground();

      if (!mounted) return;

      _returnedFilePath = _file.path;
      Navigator.pop<File>(context, _file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not apply image changes')),
        );
      }
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
      if (file.path == _returnedFilePath) continue;
      try {
        if (file.existsSync()) file.deleteSync();
      } on FileSystemException {
        continue;
      }
    }
    super.dispose();
  }

  // ================= UI =================

  BoxDecoration _previewDecoration() {
    final gradient = _selectedGradient;
    if (gradient != null && gradient.length >= 2) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      );
    }

    return BoxDecoration(color: _selectedBgColor);
  }

  Widget _buildPreview() {
    final transparent = _transparentFile;
    if (!_bgRemoved || transparent == null) {
      return Image.file(_file, key: ValueKey(_file.path), fit: BoxFit.contain);
    }

    return FittedBox(
      child: DecoratedBox(
        decoration: _previewDecoration(),
        child: Image.file(
          transparent,
          key: ValueKey(
            '${transparent.path}:${_selectedBgColor?.toARGB32()}:${_selectedGradient?.map((c) => c.toARGB32()).join(',')}',
          ),
          fit: BoxFit.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Image'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _busy ? null : () => Navigator.pop(context),
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
                : TextButton(onPressed: _done, child: const Text('Done')),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildPreview(),
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
              applyingBackground: _applyingBackground,
              selectedBackgroundColor: _selectedBgColor,
              selectedGradient: _selectedGradient,
              transparentSelected:
                  _backgroundSelectionMade &&
                  _selectedBgColor == null &&
                  _selectedGradient == null,
              activeTool: _activeTool,
            ),
          ],
        ),
      ),
    );
  }
}
