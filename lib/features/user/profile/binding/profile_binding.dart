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
  }
}
