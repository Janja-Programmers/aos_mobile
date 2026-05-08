import 'dart:io';
import 'package:image/image.dart' as img;

String applyBackgroundInIsolate(Map<String, dynamic> args) {
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

String applyGradientInIsolate(Map<String, dynamic> args) {
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
