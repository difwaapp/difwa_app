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
  Future<void> resendCode() async {
    if (!canResend.value) return;
    // Clear fields
    for (var i = 0; i < 6; i++) {
      code[i] = '';
    }
    code.refresh();

    // call verifyPhoneNumber again using stored resend token if available
    _startPhoneVerification();
  }

  // inside your OtpController class
  void _onAuthSuccess(User? user) async {
    if (user == null) {
      error.value = 'Login failed';
      Get.defaultDialog(title: 'Login failed', middleText: 'User is null');
      return;
    }

    try {
      // 1) Get FCM token (optional - handles iOS permission elsewhere)
      final fcmToken = await Get.find<FirebaseService>().getDeviceFcmToken();

      // 2) Normalize phone - ideally the controller received phone as E.164 already.
      // Ensure 'phone' variable is the normalized E.164 you used for verifyPhoneNumber.
      final normalizedPhone =
          phone; // assume already E.164; if not, normalize here

      final fs = Get.find<FirebaseService>();

      // 3) Try to find an existing user by phone number
      final existingUserDoc = await fs.findUserByPhone(normalizedPhone);

      if (existingUserDoc != null) {
        // user exists -> update lastLogin, fcmToken, and ensure uid is set
        final docId = existingUserDoc.id;
        final data = existingUserDoc.data();
        final existingRole = (data['role'] as String?) ?? 'isUser';

        // If the user doc stored a different uid, update it to current auth uid
        final existingUid = (data['uid'] as String?) ?? '';
        if (existingUid != user.uid) {
          // update uid to current auth.uid (helps linking accounts)
          await fs.updateExistingUserLogin(
            docId: docId,
            uid: user.uid,
            fcmToken: fcmToken,
          );
        } else {
          await fs.updateExistingUserLogin(docId: docId, fcmToken: fcmToken);
        }

        // 4) Route by role
        if (existingRole == 'isUser') {
          Get.offAllNamed(AppRoutes.userbottom);
        } else if (existingRole == 'isStoreKeeper' ||
            existingRole == 'isVendor') {
          // handle vendor/storekeeper role names you use
          Get.offAllNamed(AppRoutes.storebottombar);
        } else {
          // unknown role - fallback to login or a safe default screen
          Get.offAllNamed(AppRoutes.login);
        }
        return;
      }

      // 5) No existing user -> create new user doc with isUser role
      final userData = {
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'number': user.phoneNumber ?? normalizedPhone,
        'role': 'isUser',
        'floor': 'defaultFloor',
        'orderpin': 0,
        'walletBalance': 0,
        // include lat/long if you captured device location
        //'latitude': deviceLat,
        //'longitude': deviceLng,
      };

      // Use createNewUserFromAuth or createOrUpdateUserFromAuth (both present)
      await fs.createNewUserFromAuth(
        firebaseUser: user,
        userData: userData,
        addresses: null,
        fcmToken: fcmToken,
      );
      fs.startFcmTokenListenerForUser(user.uid);
      Get.offAllNamed(AppRoutes.userbottom);
    } catch (e, st) {
      print("Error saving/looking up user: $e\n$st");
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Failed to save profile: $e',
      );
      // fallback: route to phone login to retry
      Get.offAllNamed(AppRoutes.phoneLogin);
    }
  }
}
