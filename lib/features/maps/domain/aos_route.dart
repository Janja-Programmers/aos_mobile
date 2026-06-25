import 'package:flutter/foundation.dart';

@immutable
class AOSRoute {
  final double distance;
  final double durationSeconds;
  final List<AOSRouteLeg> legs;

  const AOSRoute({
    required this.distance,
    required this.durationSeconds,
    required this.legs,
  });

  String get distanceLabel => '${distance.toStringAsFixed(1)} km';

  String get durationLabel {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  factory AOSRoute.fromJson(Map<String, dynamic> json) {
    final rawLegs = json['legs'];
    return AOSRoute(
      distance: _toDouble(json['distance']),
      durationSeconds: _toDouble(json['duration_seconds']),
      legs: rawLegs is List
          ? rawLegs
                .whereType<Map>()
                .map((e) => AOSRouteLeg.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

@immutable
class AOSRouteLeg {
  final double distance;
  final double durationSeconds;
  final String? shape;

  const AOSRouteLeg({
    required this.distance,
    required this.durationSeconds,
    this.shape,
  });

  factory AOSRouteLeg.fromJson(Map<String, dynamic> json) {
    return AOSRouteLeg(
      distance: AOSRoute._toDouble(json['distance']),
      durationSeconds: AOSRoute._toDouble(json['duration_seconds']),
      shape: json['shape']?.toString(),
    );
  }
}
