import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  const LocationServiceException(
    this.message, {
    this.permanentlyDenied = false,
  });

  final String message;
  final bool permanentlyDenied;

  @override
  String toString() => message;
}

class LocationService {
  const LocationService._();

  static Future<LocationPermission> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Turn on location services to use maps.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'Location permission is required to use this map feature.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is permanently denied. Enable it in your device settings.',
        permanentlyDenied: true,
      );
    }

    return permission;
  }

  static Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
    Duration? timeLimit,
  }) async {
    await ensurePermission();
    return Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
      timeLimit: timeLimit,
    );
  }

  static Stream<Position> getNavigationPositionStream() async* {
    await ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }
}
