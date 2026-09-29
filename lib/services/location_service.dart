import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Thrown when the device location cannot be read. The message is written
/// for the user, so screens can show it directly.
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

/// Reads the device GPS so the Restaurants screen can show how far away
/// each place is.
class LocationService {
  /// How the position is requested.
  ///
  /// forceLocationManager is the important one. By default geolocator asks
  /// Google Play Services' fused location provider, which hands back a
  /// cached position whenever it judges one recent enough. That is why the
  /// first tap could report an out-of-date location and a second tap was
  /// needed to get the real one.
  ///
  /// Setting it to true makes Android use its own LocationManager, which
  /// reads the current fix every time. Slightly slower, but correct on the
  /// first attempt, which matters more here.
  static final LocationSettings _settings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    forceLocationManager: true,
    timeLimit: Duration(seconds: 15),
  );

  /// Works through the three things that can stop us getting a position,
  /// in the order they have to be checked.
  static Future<Position> currentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Location is switched off on this device. Turn it on to see how far '
        'away each restaurant is.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Location permission was denied. Distances will not be shown.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Allow it in Android '
        'Settings to see distances.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(locationSettings: _settings);
    } on TimeoutException {
      // Use the last known position if the fresh GPS request times out.
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      throw LocationException(
        'Could not get a location fix. Make sure GPS is on and try again.',
      );
    }
  }

  /// Straight-line distance in kilometres between two points.
  static double distanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final double metres = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return metres / 1000;
  }
}
