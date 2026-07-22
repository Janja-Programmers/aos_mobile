import 'dart:convert';
import 'dart:io';

Future<Object?> loadJsonFixture(
  String relativePath, {
  String baseDirectory = 'test/fixtures',
}) async {
  final String normalizedBase = baseDirectory.endsWith('/')
      ? baseDirectory.substring(0, baseDirectory.length - 1)
      : baseDirectory;
  final File file = File('$normalizedBase/$relativePath');
  final String source = await file.readAsString();
  return jsonDecode(source);
}

Future<Map<String, dynamic>> loadJsonObjectFixture(
  String relativePath, {
  String baseDirectory = 'test/fixtures',
}) async {
  final Object? decoded = await loadJsonFixture(
    relativePath,
    baseDirectory: baseDirectory,
  );
  if (decoded is! Map<Object?, Object?>) {
    throw FormatException('Expected a JSON object in $relativePath.');
  }
  return decoded.map<String, dynamic>((Object? key, Object? value) {
    return MapEntry<String, dynamic>(key.toString(), value);
  });
}

Future<List<Object?>> loadJsonListFixture(
  String relativePath, {
  String baseDirectory = 'test/fixtures',
}) async {
  final Object? decoded = await loadJsonFixture(
    relativePath,
    baseDirectory: baseDirectory,
  );
  if (decoded is! List<Object?>) {
    throw FormatException('Expected a JSON list in $relativePath.');
  }
  return decoded;
}
