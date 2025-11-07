import 'package:get/get.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseService _fs = Get.find();

  @override
  void onReady() {
    super.onReady();
    _fs.authStateChanges.listen((user) async {
      await Future.delayed(const Duration(milliseconds: 600)); // small UX delay
      if (user == null) {
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        final appUser = await _fs.fetchAppUser(user.uid);
        if (appUser == null) {
          // fallback to login
          Get.offAllNamed(AppRoutes.LOGIN);
        } else if (appUser.role == Role.vendor) {
          Get.offAllNamed(AppRoutes.VENDOR_HOME);
        } else {
          Get.offAllNamed(AppRoutes.USER_HOME);
        }
      }
    });
  }
}
