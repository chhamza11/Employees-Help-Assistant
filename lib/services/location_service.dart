import 'package:geolocator/geolocator.dart';
import '../config/app_config.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in Settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool isWithinGeofence(double latitude, double longitude) {
    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      AppConfig.officeLatitude,
      AppConfig.officeLongitude,
    );
    return distance <= AppConfig.officeRadiusMeters;
  }

  Future<bool> checkGeofence() async {
    final position = await getCurrentPosition();
    return isWithinGeofence(position.latitude, position.longitude);
  }
}
