import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  /// Request Location Permission
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  /// Get Current Location (Lat & Long)
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Convert Coordinates to Address
  static Future<Map<String, dynamic>?> getAddressFromLatLng(
      Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        return {
          "address": "${place.street}, ${place.locality}, ${place.country}",
          "pincode": place.postalCode,
          "latitude": position.latitude,
          "longitude": position.longitude,
        };
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
