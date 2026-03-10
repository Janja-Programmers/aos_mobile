import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class EditImageScreen extends ConsumerStatefulWidget {
  const EditImageScreen({super.key, required this.file});

  final File file;

  @override
  ConsumerState<EditImageScreen> createState() => _EditImageScreenState();
}

class _EditImageScreenState extends ConsumerState<EditImageScreen> {
  late File _file;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  Future<void> _crop() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: _file.path,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: "Crop", lockAspectRatio: false),
        IOSUiSettings(title: "Crop"),
      ],
    );

    if (cropped == null) return;

    setState(() => _file = File(cropped.path));
  }

  Future<void> _rotate() async {
    final bytes = await _file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return;

    final rotated = img.copyRotate(image, angle: 90);

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final file = File(path)..writeAsBytesSync(img.encodeJpg(rotated));

    setState(() => _file = file);
  }

  Future<void> _compress() async {
    final dir = await getTemporaryDirectory();
    final target = "${dir.path}/compressed.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      _file.path,
      target,
      quality: 80,
    );

    if (result != null) {
      setState(() => _file = File(result.path));
    }
  }

  Future<void> _removeBg() async {
    setState(() => _busy = true);

    /// TODO: integrate remove.bg API

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _busy = false);
  }

  void _done() async {
    await _compress();
    if (!mounted) return;
    Navigator.pop(context, _file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Image"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : _done,
            child: const Text("Done"),
          ),
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
                  child: Image.file(_file, fit: BoxFit.contain),
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
