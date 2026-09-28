import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String?> getLocationError() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return 'Location services are disabled. Please enable GPS.';
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'Location permission was denied.';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is permanently denied. '
          'Please enable it from Settings.';
    }

    return null;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final error = await getLocationError();

      if (error != null) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}