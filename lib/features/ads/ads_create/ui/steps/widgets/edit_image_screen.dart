import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

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

  /// Track temporary files created during editing
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
        AndroidUiSettings(toolbarTitle: "Crop", lockAspectRatio: false),
        IOSUiSettings(title: "Crop"),
      ],
    );

    if (cropped == null) return;

    final file = File(cropped.path);

    _tempFiles.add(file);

    setState(() {
      _file = file;
    });
  }

  // ================= ROTATE =================

  Future<void> _rotate() async {
    final bytes = await _file.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) return;

    final rotated = img.copyRotate(image, angle: 90);

    final dir = await getTemporaryDirectory();

    final path =
        "${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final file = File(path)..writeAsBytesSync(img.encodeJpg(rotated));

    _tempFiles.add(file);

    setState(() {
      _file = file;
    });
  }

  // ================= COMPRESS =================

  Future<void> _compress() async {
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

      setState(() {
        _file = file;
      });
    }
  }

  // ================= REMOVE BG (future feature) =================

  Future<void> _removeBg() async {
    setState(() => _busy = true);

    /// TODO: integrate remove.bg API

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _busy = false);
  }

  // ================= DONE =================

  Future<void> _done() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      // compress final image
      await _compress();

      if (!mounted) return;

      final controller = ref.read(adDraftControllerProvider.notifier);

      // replace image in draft
      await controller.replaceImageAt(widget.index, _file);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint("EditImageScreen _done error: $e");
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
        if (file.existsSync()) {
          file.deleteSync();
        }
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
            /// Image preview
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      _file,
                      key: ValueKey(_file.path), // prevents preview glitches
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            /// Tools
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tool(Icons.crop, "Crop", _crop),
                  _tool(Icons.rotate_right, "Rotate", _rotate),
                  _tool(Icons.auto_fix_high, "Remove BG", _removeBg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tool(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _busy ? null : onTap,
      child: Column(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
