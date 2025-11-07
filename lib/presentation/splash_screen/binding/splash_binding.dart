import 'package:get/get.dart';
import '../../../data/services/firebase_service.dart';
import '../controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
