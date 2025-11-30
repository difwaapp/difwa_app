import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:get/get.dart';

class VendorFormBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure FirebaseService is registered
    if (!Get.isRegistered<FirebaseService>()) {
      Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    }

    // Register VendorsController if not already registered
    if (!Get.isRegistered<VendorsController>()) {
      Get.lazyPut<VendorsController>(() => VendorsController(), fenix: true);
    }

    // Register AddressController if not already registered
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    }
  }
}
