import 'dart:convert';
import 'dart:io';

Future<Object?> loadJsonFixture(String relativePath) async {
  final File file = File('test/fixtures/$relativePath');
  final String source = await file.readAsString();
  return jsonDecode(source);
}

Future<Map<String, dynamic>> loadJsonObjectFixture(String relativePath) async {
  final Object? decoded = await loadJsonFixture(relativePath);
  if (decoded is! Map<Object?, Object?>) {
    throw FormatException('Expected a JSON object in $relativePath.');
  }
  return decoded.map<String, dynamic>((Object? key, Object? value) {
    return MapEntry<String, dynamic>(key.toString(), value);
  });
}

Future<List<Object?>> loadJsonListFixture(String relativePath) async {
  final Object? decoded = await loadJsonFixture(relativePath);
  if (decoded is! List<Object?>) {
    throw FormatException('Expected a JSON list in $relativePath.');
  }
  return decoded;
}
