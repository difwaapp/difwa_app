import 'package:difwa_app/features/auth/otp_verification/controller/otp_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments ?? {};
    final phone = args['phone'] as String;
    final vid = args['verificationId'] as String?;
    final rtoken = args['resendToken'] as int?;
    Get.lazyPut(() => OtpController(phone: phone, initialVerificationId: vid, initialResendToken: rtoken));
  }
}
