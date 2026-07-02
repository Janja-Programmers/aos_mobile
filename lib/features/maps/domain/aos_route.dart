import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:flutter/foundation.dart';

@immutable
class AOSRoute {
  final int? status;
  final String? statusMessage;
  final String? units;
  final String? language;
  final String shapeFormat;
  final double distance;
  final String? distanceDisplay;
  final double durationSeconds;
  final String? durationDisplay;
  final bool trafficEnabled;
  final String? trafficSource;
  final List<AOSRouteLeg> legs;

  const AOSRoute({
    this.status,
    this.statusMessage,
    this.units,
    this.language,
    this.shapeFormat = 'polyline6',
    required this.distance,
    this.distanceDisplay,
    required this.durationSeconds,
    this.durationDisplay,
    this.trafficEnabled = false,
    this.trafficSource,
    required this.legs,
  });

  String get distanceLabel =>
      distanceDisplay ?? '${distance.toStringAsFixed(1)} km';

  String get durationLabel {
    if (durationDisplay?.trim().isNotEmpty ?? false) return durationDisplay!;
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String? get firstShape {
    for (final leg in legs) {
      final shape = leg.shape;
      if (shape != null && shape.isNotEmpty) return shape;
    }
    return null;
  }

  List<AOSRouteManeuver> get maneuvers =>
      legs.expand((leg) => leg.maneuvers).toList(growable: false);

  factory AOSRoute.fromJson(Map<String, dynamic> json) {
    final rawLegs = json['legs'];
    return AOSRoute(
      status: _toInt(json['status']),
      statusMessage: _string(json['status_message']),
      units: _string(json['units']),
      language: _string(json['language']),
      shapeFormat: _string(json['shape_format']) ?? 'polyline6',
      distance: _toDouble(json['distance']),
      distanceDisplay: _string(json['distance_display']),
      durationSeconds: _toDouble(json['duration_seconds']),
      durationDisplay: _string(json['duration_display']),
      trafficEnabled: _toBool(json['traffic_enabled']),
      trafficSource: _string(json['traffic_source']),
      legs: asJsonMapList(rawLegs).map(AOSRouteLeg.fromJson).toList(),
    );
  }

  static double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    final clean = value?.toString().trim().toLowerCase();
    return clean == '1' || clean == 'true' || clean == 'yes';
  }

  static String? _string(dynamic value) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v == 'null') return null;
    return v;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty && e != 'null')
        .toList(growable: false);
  }
}

@immutable
class AOSRouteLeg {
  final int index;
  final double distance;
  final String? distanceDisplay;
  final double durationSeconds;
  final String? durationDisplay;
  final String? shape;
  final String? shapeFormat;
  final List<AOSRouteManeuver> maneuvers;

  const AOSRouteLeg({
    this.index = 0,
    required this.distance,
    this.distanceDisplay,
    required this.durationSeconds,
    this.durationDisplay,
    this.shape,
    this.shapeFormat,
    this.maneuvers = const [],
  });

  factory AOSRouteLeg.fromJson(Map<String, dynamic> json) {
    final rawManeuvers = json['maneuvers'];
    return AOSRouteLeg(
      index: AOSRoute._toInt(json['index']) ?? 0,
      distance: AOSRoute._toDouble(json['distance']),
      distanceDisplay: AOSRoute._string(json['distance_display']),
      durationSeconds: AOSRoute._toDouble(json['duration_seconds']),
      durationDisplay: AOSRoute._string(json['duration_display']),
      shape: AOSRoute._string(json['shape']),
      shapeFormat: AOSRoute._string(json['shape_format']),
      maneuvers: asJsonMapList(
        rawManeuvers,
      ).map(AOSRouteManeuver.fromJson).toList(),
    );
  }
}

@immutable
class AOSRouteManeuver {
  final int index;
  final int? type;
  final String? instruction;
  final String? verbalTransitionAlertInstruction;
  final String? verbalPreTransitionInstruction;
  final String? verbalPostTransitionInstruction;
  final List<String> streetNames;
  final List<String> beginStreetNames;
  final double distance;
  final String? distanceDisplay;
  final double durationSeconds;
  final String? durationDisplay;
  final int? beginShapeIndex;
  final int? endShapeIndex;
  final String? travelMode;
  final String? travelType;
  final bool toll;
  final bool rough;
  final bool highway;
  final bool ferry;
  final int? roundaboutExitCount;

  const AOSRouteManeuver({
    this.index = 0,
    this.type,
    this.instruction,
    this.verbalTransitionAlertInstruction,
    this.verbalPreTransitionInstruction,
    this.verbalPostTransitionInstruction,
    this.streetNames = const [],
    this.beginStreetNames = const [],
    this.distance = 0,
    this.distanceDisplay,
    this.durationSeconds = 0,
    this.durationDisplay,
    this.beginShapeIndex,
    this.endShapeIndex,
    this.travelMode,
    this.travelType,
    this.toll = false,
    this.rough = false,
    this.highway = false,
    this.ferry = false,
    this.roundaboutExitCount,
  });

  String get bestVoiceText =>
      verbalPreTransitionInstruction ??
      instruction ??
      verbalTransitionAlertInstruction ??
      verbalPostTransitionInstruction ??
      'Continue';

  String get alertVoiceText =>
      verbalTransitionAlertInstruction ?? bestVoiceText;

  factory AOSRouteManeuver.fromJson(Map<String, dynamic> json) {
    return AOSRouteManeuver(
      index: AOSRoute._toInt(json['index']) ?? 0,
      type: AOSRoute._toInt(json['type']),
      instruction: AOSRoute._string(json['instruction']),
      verbalTransitionAlertInstruction: AOSRoute._string(
        json['verbal_transition_alert_instruction'],
      ),
      verbalPreTransitionInstruction: AOSRoute._string(
        json['verbal_pre_transition_instruction'],
      ),
      verbalPostTransitionInstruction: AOSRoute._string(
        json['verbal_post_transition_instruction'],
      ),
      streetNames: AOSRoute._stringList(json['street_names']),
      beginStreetNames: AOSRoute._stringList(json['begin_street_names']),
      distance: AOSRoute._toDouble(json['distance']),
      distanceDisplay: AOSRoute._string(json['distance_display']),
      durationSeconds: AOSRoute._toDouble(json['duration_seconds']),
      durationDisplay: AOSRoute._string(json['duration_display']),
      beginShapeIndex: AOSRoute._toInt(json['begin_shape_index']),
      endShapeIndex: AOSRoute._toInt(json['end_shape_index']),
      travelMode: AOSRoute._string(json['travel_mode']),
      travelType: AOSRoute._string(json['travel_type']),
      toll: AOSRoute._toBool(json['toll']),
      rough: AOSRoute._toBool(json['rough']),
      highway: AOSRoute._toBool(json['highway']),
      ferry: AOSRoute._toBool(json['ferry']),
      roundaboutExitCount: AOSRoute._toInt(json['roundabout_exit_count']),
    );
  }
}
