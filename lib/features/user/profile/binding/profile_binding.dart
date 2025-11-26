import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:get/get.dart';
import '../../../../services/firebase_service.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirebaseService>()) {
      Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    }

    Get.put(FirebaseService());
    Get.lazyPut<ProfileController>(() => ProfileController());
    // Use lazyPut if controller expensive; use put if you want immediately available instance
    Get.lazyPut<VendorsController>(() => VendorsController(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
  }
}
