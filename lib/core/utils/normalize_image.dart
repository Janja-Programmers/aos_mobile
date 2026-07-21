import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

Future<File> normalizeImageOrientation(File file) async {
  final normalizedPath =
      '${file.parent.path}${Platform.pathSeparator}'
      'aos_normalized_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final outputPath = await Isolate.run<String?>(
    () => _normalizeImageFile(
      sourcePath: file.path,
      normalizedPath: normalizedPath,
    ),
  );

  return outputPath == null ? file : File(outputPath);
}

String? _normalizeImageFile({
  required String sourcePath,
  required String normalizedPath,
}) {
  final bytes = File(sourcePath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);

  if (decoded == null) return null;

  final fixed = img.bakeOrientation(decoded);
  final outBytes = Uint8List.fromList(img.encodeJpg(fixed, quality: 90));
  File(normalizedPath).writeAsBytesSync(outBytes, flush: true);

  return normalizedPath;
}
