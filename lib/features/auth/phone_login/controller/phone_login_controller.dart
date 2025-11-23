import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/utils/phone_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PhoneLoginController extends GetxController {
  final phoneCtrl = TextEditingController();
  final acceptTerms = false.obs;
  final loading = false.obs;
  final error = RxnString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int? _resendToken;

  Future<void> sendOtp({String defaultCountryCode = '+91'}) async {
    final raw = phoneCtrl.text.trim();
    error.value = null;

    final normalized = normalizeToE164(raw, defaultCountryCode: defaultCountryCode);
    if (normalized == null) {
      Get.snackbar('Invalid number', 'Please enter a valid phone number with country code.');
      return;
    }
    if (!acceptTerms.value) {
      Get.snackbar('Accept terms', 'Please accept terms and conditions');
      return;
    }

    loading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: normalized,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // auto sign-in (Android)
          try {
            final cred = await _auth.signInWithCredential(credential);
            _onAuthSuccess(cred.user);
          } catch (e) {
            Get.snackbar('Auto sign-in failed', e.toString());
          }
        },
        verificationFailed: (e) {
          error.value = e.message;
          Get.snackbar('Verification failed', e.message ?? 'Unknown error');
        },
        codeSent: (verificationId, resendToken) {
          _resendToken = resendToken;
          loading.value = false;
          Get.toNamed(AppRoutes.otpVerification, arguments: {
            'phone': normalized,
            'verificationId': verificationId,
            'resendToken': resendToken,
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // ignored here
        },
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  // called when verifyPhone credentials lead to instant sign-in
  Future<void> _onAuthSuccess(User? user) async {
    // You may want to route users similarly to OTP controller logic
    if (user != null) {
      Get.offAllNamed(AppRoutes.userDashbord);
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}
