import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  static final LocationSettings _settings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    forceLocationManager: true,
    timeLimit: Duration(seconds: 15),
  );

  static Future<Position> currentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Location is switched off on this device. Turn it on to set the '
        'restaurant location.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Location permission was denied. Restaurant location was not captured.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Allow it in Android '
        'Settings to set the restaurant location.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(locationSettings: _settings);
    } on TimeoutException {
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      throw LocationException(
        'Could not get a location fix. Make sure GPS is on and try again.',
      );
    }
  }
}
