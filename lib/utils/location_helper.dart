import 'package:difwa_app/config/core/app_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static Future<bool> requestLocationPermission() async {
  // Check current status
  final status = await Permission.location.status;

  if (status.isGranted) return true;
  final result = await Permission.location.request();

  if (result.isGranted) return true;

  if (result.isPermanentlyDenied) {
    Get.snackbar(
      'Permission required',
      'Location permission is permanently denied. Open settings to enable it.',
      snackPosition: SnackPosition.BOTTOM,
    );
    openAppSettings();
    return false;
  }

  // denied or restricted
  return false;
}


  /// Get Current Location (Lat & Long)
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await requestLocationPermission();
    print("hasPermission : $hasPermission");
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
