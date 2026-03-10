import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<File> urlToFile(String url) async {
  final dio = Dio();

  final response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  final bytes = Uint8List.fromList(response.data!);

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  await file.writeAsBytes(bytes);

  return file;
}
