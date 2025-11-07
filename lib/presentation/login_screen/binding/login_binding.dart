import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../../../core/app_export.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
