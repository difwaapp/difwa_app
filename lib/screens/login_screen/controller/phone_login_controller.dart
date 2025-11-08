import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneLoginController extends GetxController {
  final phoneCtrl = TextEditingController(text: '');
  final acceptTerms = false.obs;
  final loading = false.obs;

  /// Basic phone validation (very basic)
  bool isPhoneValid(String phone) {
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    // simple pattern: + and digits or just digits, length 8-15
    return RegExp(r'^\+?\d{8,15}$').hasMatch(normalized);
  }

  Future<void> sendOtp() async {
    final phone = phoneCtrl.text.trim();
    if (!isPhoneValid(phone)) {
      Get.snackbar('Invalid number', 'Please enter a valid phone number including country code',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!acceptTerms.value) {
      Get.snackbar('Accept terms', 'Please accept terms and conditions to continue',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      loading.value = true;

      // TODO: Replace the below with your FirebaseService or AuthController call
      // Example: await Get.find<AuthController>().sendOtpToPhone(phone);
      await Future.delayed(const Duration(seconds: 1)); // simulate network

      // Navigate to OTP verification screen - pass phone number as argument
      // Get.toNamed(AppRoutes.otpVerification, arguments: {'phone': phone});
    } catch (e) {
      Get.snackbar('Error', 'Could not send OTP. Try again later.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      loading.value = true;
      // TODO: integrate Google Sign-In
      await Future.delayed(const Duration(seconds: 1));
      // after successful google login route to app home
      // Get.offAllNamed(AppRoutes.appNavigationScreen);
    } catch (e) {
      Get.snackbar('Google Sign-In failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}
