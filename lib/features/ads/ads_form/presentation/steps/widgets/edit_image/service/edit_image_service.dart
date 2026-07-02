import 'dart:io';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageEditService {
  static Future<File?> rotate(File file) async {
    final bytes = await file.readAsBytes();

    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final rotated = img.copyRotate(image, angle: 90);

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.png';

    final newFile = File(path)..writeAsBytesSync(img.encodePng(rotated));

    return newFile;
  }

  static Future<File?> applyBackground(
    File transparentFile,
    Color color,
  ) async {
    final bytes = await transparentFile.readAsBytes();

    final foreground = img.decodeImage(bytes);
    if (foreground == null) return null;

    final background = img.Image(
      width: foreground.width,
      height: foreground.height,
    );

    img.fill(
      background,
      color: img.ColorRgb8(
        (color.r * 255.0).round().clamp(0, 255),
        (color.g * 255.0).round().clamp(0, 255),
        (color.b * 255.0).round().clamp(0, 255),
      ),
    );

    img.compositeImage(background, foreground);

    final dir = await getTemporaryDirectory();

    final path = '${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(path)..writeAsBytesSync(img.encodePng(background));

    return file;
  }
}
