import 'dart:async';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class OtpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String phone;
  final String? initialVerificationId;
  final int? initialResendToken;

  OtpController({
    required this.phone,
    this.initialVerificationId,
    this.initialResendToken,
  });

  final code = List<String>.filled(6, '').obs;
  final loading = false.obs;
  final error = RxnString();
  final sent = false.obs;
  final verificationId = RxnString();
  final canResend = false.obs;
  Timer? _resendTimer;
  final resendSeconds = 60.obs;

  int? _resendToken;

  @override
  void onInit() {
    super.onInit();

    // If verificationId was passed from previous screen, use it and assume code was sent.
    if (initialVerificationId != null && initialVerificationId!.isNotEmpty) {
      verificationId.value = initialVerificationId;
      _resendToken = initialResendToken;
      sent.value = true;
      _startResendTimer(); // start local resend timer
    } else {
      // otherwise, start verification flow here
      _startPhoneVerification();
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void _startPhoneVerification() async {
    error.value = null;
    loading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android automatic verification (instant), sign in directly
          try {
            loading.value = true;
            final userCred = await _auth.signInWithCredential(credential);
            _onAuthSuccess(userCred.user);
          } catch (e) {
            error.value = 'Auto sign-in failed: $e';
            Get.defaultDialog(
              title: 'Error',
              middleText: error.value ?? 'Auto sign-in failed',
            );
          } finally {
            loading.value = false;
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          loading.value = false;
          error.value = e.message ?? 'Verification failed';
          Get.defaultDialog(
            title: 'Verification failed',
            middleText: error.value ?? 'Unknown error',
          );
        },
        codeSent: (String verId, int? resendToken) {
          loading.value = false;
          verificationId.value = verId;
          _resendToken = resendToken;
          sent.value = true;
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      loading.value = false;
      error.value = e.toString();
      Get.defaultDialog(
        title: 'Error',
        middleText: error.value ?? 'Unknown error',
      );
    }
  }

  void _startResendTimer() {
    resendSeconds.value = 60;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (t) {
      final s = resendSeconds.value - 1;
      if (s <= 0) {
        t.cancel();
        canResend.value = true;
        resendSeconds.value = 0;
      } else {
        resendSeconds.value = s;
      }
    });
  }

  void updateDigit(int index, String value) {
    if (index < 0 || index >= 6) return;
    code[index] = value.trim();
    code.refresh();
    // If all digits filled, attempt submit automatically
    final joined = code.join();
    if (joined.length == 6 && !joined.contains('')) {
      submitOtp();
    }
  }

  Future<void> submitOtp() async {
    final joined = code.join();
    if (joined.length != 6) {
      error.value = 'Enter the 6-digit code';
      Get.defaultDialog(title: 'Invalid OTP', middleText: error.value!);
      return;
    }
    final verId = verificationId.value;
    if (verId == null || verId.isEmpty) {
      error.value = 'No verification ID. Please request a new code.';
      Get.defaultDialog(title: 'Error', middleText: error.value!);
      return;
    }

    loading.value = true;
    error.value = null;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: joined,
      );
      final userCred = await _auth.signInWithCredential(credential);
      _onAuthSuccess(userCred.user);
    } on FirebaseAuthException catch (e) {
      loading.value = false;
      error.value = e.message ?? 'Invalid code';
      // show a dialog with retry option
      Get.defaultDialog(
        title: 'OTP not valid',
        middleText: error.value!,
        textConfirm: 'Retry',
        onConfirm: () {
          Get.back(); // close dialog
        },
      );
    } catch (e) {
      loading.value = false;
      error.value = e.toString();
      Get.defaultDialog(
        title: 'Error',
        middleText: error.value ?? 'Unknown error',
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value) return;
    // Clear fields
    for (var i = 0; i < 6; i++) code[i] = '';
    code.refresh();

    // call verifyPhoneNumber again using stored resend token if available
    _startPhoneVerification();
  }

void _onAuthSuccess(User? user) async {
  if (user == null) {
    error.value = 'Login failed';
    Get.defaultDialog(title: 'Login failed', middleText: 'User is null');
    return;
  }

  try {
    // get device token (requests permission on iOS)
    final fcmToken = await Get.find<FirebaseService>().getDeviceFcmToken();
    // optionally call a helper that requests permission first:
    // final fcmToken = await requestAndGetFcmToken();

    // build userData as before
    final userData = {
      'email': user.email ?? '',
      'name': user.displayName ?? '',
      'number': user.phoneNumber ?? phone,
      'role': 'isUser',
      'floor': 'defaultFloor',
      'orderpin': 0,
      'walletBalance': 0,
      // add latitude/longitude if you have it
    };

    // upsert user and include fcmToken
    await Get.find<FirebaseService>().createOrUpdateUserFromAuth(
      firebaseUser: user,
      userData: userData,
      addresses: null,
      fcmToken: fcmToken,
    );

    // start listening for token refresh (optional)
    Get.find<FirebaseService>().startFcmTokenListenerForUser(user.uid);

    // go to dashboard
    Get.offAllNamed(AppRoutes.home);
  } catch (e) {
    print("Error middleText: 'Failed to save profile: $e' ",);
    Get.defaultDialog(title: 'Error', middleText: 'Failed to save profile: $e');
    Get.offAllNamed(AppRoutes.phoneLogin);
  }
}
}