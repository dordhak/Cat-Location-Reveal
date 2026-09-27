import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';

class LocationUtils {
  LocationUtils._();

  /// Handles the full permission dance and returns the current position.
  /// Throws an AppException with a user-friendly message if it can't.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException(
        'Location services are turned off. Please enable them to spot a cat.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const AppException(
          'Location permission denied. We need this to tag where cats are spotted.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        'Location permission permanently denied. Please enable it in app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}