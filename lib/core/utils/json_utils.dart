/// Small helpers for defensive JSON parsing at API boundaries.
///
/// These keep strict-casts / strict-inference happy without trusting backend
/// payloads more than necessary.
Map<String, dynamic> asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is List<Object?> && value.isNotEmpty) {
    return asJsonMap(value.first);
  }
  if (value is Iterable<Object?> && value.isNotEmpty) {
    return asJsonMap(value.first);
  }
  return <String, dynamic>{};
}

List<Object?> asJsonList(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is Iterable<Object?>) {
    return value.toList(growable: false);
  }
  if (value is Iterable) {
    return value.cast<Object?>().toList(growable: false);
  }
  return <Object?>[];
}

List<Map<String, dynamic>> asJsonMapList(Object? value) => asJsonList(value)
    .map(asJsonMap)
    .where((Map<String, dynamic> item) => item.isNotEmpty)
    .toList(growable: false);

String asString(Object? value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? asNullableString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? asNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double asDouble(Object? value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? asNullableDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

bool asBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return fallback;
}
