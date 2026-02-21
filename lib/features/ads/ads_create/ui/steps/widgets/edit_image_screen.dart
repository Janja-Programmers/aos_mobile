import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class EditImagePage extends StatefulWidget {
  final File file;

  const EditImagePage({super.key, required this.file});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late File _currentFile;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _currentFile = widget.file;
  }

  // ================= CROP =================
  Future<void> _crop() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: _currentFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
        ),
        IOSUiSettings(title: 'Crop'),
      ],
    );

    if (cropped == null) return;

    setState(() {
      _currentFile = File(cropped.path);
    });
  }

  // ================= REMOVE BG =================
  Future<void> _removeBg() async {
    setState(() => _processing = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    request.headers['X-Api-Key'] = 'YOUR_REMOVE_BG_API_KEY';

    request.files.add(
      await http.MultipartFile.fromPath('image_file', _currentFile.path),
    );

    request.fields['size'] = 'auto';

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/no_bg.png');
      await file.writeAsBytes(bytes);

      setState(() {
        _currentFile = file;
      });
    }

    setState(() => _processing = false);
  }

  // ================= CHANGE BG COLOR =================
  Future<void> _changeBackground(Color color) async {
    setState(() => _processing = true);

    final bytes = await _currentFile.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final background = img.Image(width: image.width, height: image.height);

    final fillColor = img.ColorRgb8(color.red, color.green, color.blue);

    img.fill(background, color: fillColor);

    img.compositeImage(background, image, blend: img.BlendMode.alpha);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/bg_changed.png');
    await file.writeAsBytes(img.encodePng(background));

    setState(() {
      _currentFile = file;
      _processing = false;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Image"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _currentFile);
            },
            child: const Text("Done"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(child: Image.file(_currentFile)),
                if (_processing)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EditButton(icon: Icons.crop, label: "Crop", onTap: _crop),
              _EditButton(
                icon: Icons.auto_fix_high,
                label: "Remove BG",
                onTap: _removeBg,
              ),
              _EditButton(
                icon: Icons.palette,
                label: "Background",
                onTap: () => _changeBackground(Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EditButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
            ),
            child: Icon(icon),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
