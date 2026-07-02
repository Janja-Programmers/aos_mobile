import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

Future<File> normalizeImageOrientation(File file) async {
  final bytes = await file.readAsBytes();

  final decoded = img.decodeImage(bytes);
  if (decoded == null) return file;

  // This applies EXIF orientation and removes it by re-encoding pixels correctly
  final fixed = img.bakeOrientation(decoded);

  // Re-encode (jpg)
  final outBytes = Uint8List.fromList(img.encodeJpg(fixed, quality: 90));

  final outFile = File(
    file.path,
  ); // overwrite same file OR create a new temp file
  await outFile.writeAsBytes(outBytes, flush: true);
  return outFile;
}
