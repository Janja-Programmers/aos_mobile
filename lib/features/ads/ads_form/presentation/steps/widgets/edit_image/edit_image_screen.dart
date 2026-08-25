import 'dart:io';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
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

  EditorToolAction? _activeTool;

  Color? _selectedBgColor;
  List<Color>? _selectedGradient;

  File? _transparentFile;

  final List<File> _tempFiles = [];

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  // ================= CROP =================

  Future<void> _crop() async {
    if (_activeTool != null) return;

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

      setState(() => _file = file);
    } finally {
      if (mounted) {
        setState(() => _activeTool = null);
      }
    }
  }

  // ================= ROTATE =================

  Future<void> _rotate() async {
    if (_activeTool != null) return;

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

      setState(() => _file = file);
    } finally {
      if (mounted) {
        setState(() => _activeTool = null);
      }
    }
  }

  // ================= COMPRESS =================

  Future<void> _compress() async {
    if (_selectedBgColor == null) return;

    final prepared = await ref
        .read(mediaPreparationServiceProvider)
        .prepare(
          media: AcquiredMedia.external(file: _file, kind: MediaKind.image),
          useCase: MediaUseCase.adImage,
        );

    if (prepared.ownedByPreparation) {
      _tempFiles.add(prepared.file);

      if (!mounted) return;
      setState(() => _file = prepared.file);
    } else {
      await prepared.discard();
    }
  }

  // ================= REMOVE BG =================

  Future<void> _removeBg() async {
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

    setState(() {
      _busy = false;
      _activeTool = null;
    });

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

    if (accepted ?? false) {
      setState(() {
        _file = removedFile;
        _transparentFile = removedFile;
        _bgRemoved = true;
        _selectedBgColor = null;
        _selectedGradient = null;
      });
    } else {
      setState(() {
        _file = originalFile;
        _transparentFile = null;
        _bgRemoved = false;
        _selectedBgColor = null;
        _selectedGradient = null;
      });
    }
  }

  // ================= APPLY BACKGROUND =================

  Future<void> _applyBackground(Color? color) async {
    if (_transparentFile == null) return;

    setState(() {
      _selectedBgColor = color;
      _selectedGradient = null;
    });

    if (_applyingBackground) return;

    setState(() => _applyingBackground = true);

    try {
      final dir = await getTemporaryDirectory();

      final outputPath =
          '${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.png';

      final resultPath = await compute(applyBackgroundInIsolate, {
        'sourcePath': _transparentFile!.path,
        'outputPath': outputPath,
        'color': color?.toARGB32(),
      });

      final file = File(resultPath);

      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
      });
    } finally {
      if (mounted) {
        setState(() => _applyingBackground = false);
      }
    }
  }
  // ================= APPLY GRADIENT =================

  Future<void> _applyGradient(List<Color> colors) async {
    if (_transparentFile == null) return;

    setState(() {
      _selectedGradient = colors;
      _selectedBgColor = colors.first;
    });

    if (_applyingBackground) return;

    setState(() => _applyingBackground = true);

    try {
      final dir = await getTemporaryDirectory();

      final outputPath =
          '${dir.path}/gradient_${DateTime.now().millisecondsSinceEpoch}.png';

      final resultPath = await compute(applyGradientInIsolate, {
        'sourcePath': _transparentFile!.path,
        'outputPath': outputPath,
        'startColor': colors[0].toARGB32(),
        'endColor': colors[1].toARGB32(),
      });

      final file = File(resultPath);

      _tempFiles.add(file);

      if (!mounted) return;

      setState(() {
        _file = file;
      });
    } finally {
      if (mounted) {
        setState(() => _applyingBackground = false);
      }
    }
  }

  // ================= DONE =================

  Future<void> _done() async {
    if (_busy) return;

    if (_bgRemoved && _selectedBgColor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a background')));
      return;
    }

    setState(() => _busy = true);

    try {
      await _compress();

      if (!mounted) return;

      Navigator.pop<File>(context, _file);
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
          title: const Text('Edit Image'),
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
                : TextButton(onPressed: _done, child: const Text('Done')),
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
              applyingBackground: _applyingBackground,
              selectedBackgroundColor: _selectedBgColor,
              selectedGradient: _selectedGradient,
              activeTool: _activeTool,
            ),
          ],
        ),
      ),
    );
  }
}
