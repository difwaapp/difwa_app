import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:difwa_app/routes/app_routes.dart';

class PhoneLoginController extends GetxController {
  final phoneCtrl = TextEditingController(text: '');
  final acceptTerms = false.obs;
  final loading = false.obs;
  final error = RxnString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int? _resendToken;


/// Returns a normalized E.164 string or null if it cannot be normalized.
/// - `raw` is what the user typed (may contain spaces, dashes, parentheses).
/// - `defaultCountryCode` should include the leading plus, e.g. "+91".
String? normalizeToE164(String raw, {String defaultCountryCode = '+91'}) {
  if (raw == null) return null;
  String s = raw.trim();

  // remove common separators
  s = s.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // if starts with 00, convert to +
  if (s.startsWith('00')) s = s.replaceFirst('00', '+');

  // if already starts with + and digits -> check
  if (s.startsWith('+')) {
    if (RegExp(r'^\+\d{6,15}$').hasMatch(s)) return s;
    return null; // invalid chars or length
  }

  // if starts with digits and length plausible, prepend default country code
  // If user typed leading national 0, strip it before prepending
  if (RegExp(r'^\d+$').hasMatch(s)) {
    // handle leading zero (e.g., 0912345678) -> remove 0
    if (s.startsWith('0')) s = s.replaceFirst(RegExp(r'^0+'), '');
    final candidate = defaultCountryCode + s;
    if (RegExp(r'^\+\d{6,15}$').hasMatch(candidate)) return candidate;
  }

  return null; // could not normalize
}


  /// Basic phone validation (very basic)
  bool isPhoneValid(String phone) {
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    // simple pattern: + and digits or just digits, length 8-15
    return RegExp(r'^\+?\d{8,15}$').hasMatch(normalized);
  }

Future<void> sendOtp() async {
  final rawPhone = phoneCtrl.text.trim();
  error.value = null;
  // Normalize using default country code +91 (change if needed)
  final normalized = normalizeToE164(rawPhone, defaultCountryCode: '+91');

  if (normalized == null) {
    Get.snackbar(
      'Invalid number',
      'Enter phone in international format (e.g. +919188533893) or include country code.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  if (!acceptTerms.value) {
    Get.snackbar(
      'Accept terms',
      'Please accept terms and conditions to continue',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  loading.value = true;

  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        loading.value = true;
        try {
          final credentialResult = await _auth.signInWithCredential(credential);
          _onAuthSuccess(credentialResult.user);
        } catch (e) {
          Get.snackbar('Auto sign-in failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
        } finally {
          loading.value = false;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        loading.value = false;
        error.value = e.message;
        Get.snackbar('Verification failed', e.message ?? 'Unknown error', snackPosition: SnackPosition.BOTTOM);
      },
      codeSent: (String verificationId, int? resendToken) {
        loading.value = false;
        _resendToken = resendToken;
        Get.toNamed(AppRoutes.otpVerification, arguments: {
          'phone': normalized,
          'verificationId': verificationId,
          'resendToken': resendToken,
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        loading.value = false;
      },
    );
  } catch (e) {
    loading.value = false;
    Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  }
}


  /// Start phone verification with Firebase. On codeSent we'll navigate to OTP screen
  // Future<void> sendOtp() async {
  //   final phone = phoneCtrl.text.trim();
  //   error.value = null;

  //   if (!isPhoneValid(phone)) {
  //     Get.snackbar(
  //       'Invalid number',
  //       'Please enter a valid phone number including country code',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }
  //   if (!acceptTerms.value) {
  //     Get.snackbar(
  //       'Accept terms',
  //       'Please accept terms and conditions to continue',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }

  //   loading.value = true;

  //   try {
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: phone,
  //       timeout: const Duration(seconds: 60),
  //       forceResendingToken: _resendToken,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         // This callback might be called automatically on Android devices (instant verification).
  //         // We attempt to sign in with the provided credential.
  //         try {
  //           loading.value = true;
  //           final credentialResult = await _auth.signInWithCredential(credential);
  //           _onAuthSuccess(credentialResult.user);
  //         } catch (e) {
  //           Get.snackbar('Auto sign-in failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //         } finally {
  //           loading.value = false;
  //         }
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         loading.value = false;
  //         error.value = e.message;
  //         Get.snackbar('Verification failed', e.message ?? 'Unknown error', snackPosition: SnackPosition.BOTTOM);
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         loading.value = false;
  //         _resendToken = resendToken;
  //         // Navigate to OTP screen and pass verificationId and phone
  //         Get.toNamed(AppRoutes.otpVerification, arguments: {
  //           'phone': phone,
  //           'verificationId': verificationId,
  //           'resendToken': resendToken,
  //         });
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // Auto-retrieval timed out; verificationId might still be useful if user enters OTP
  //         loading.value = false;
  //         // no navigation here — user should be on OTP screen if codeSent fired earlier
  //       },
  //     );
  //   } catch (e) {
  //     loading.value = false;
  //     error.value = e.toString();
  //     Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
  //   }
  // }

  /// Optionally expose a resend helper that calls verifyPhoneNumber again with the token
  Future<void> resendOtp(String phone) async {
    // re-use sendOtp logic but set forceResendingToken if available
    // The token is managed in _resendToken during codeSent
    await sendOtp();
  }

  Future<void> _onAuthSuccess(User? user) async {
    if (user == null) {
      Get.snackbar('Login failed', 'No user returned', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // TODO: After sign-in you probably want to ensure the Firestore user document exists.
    // Example:
    // final fs = Get.find<FirebaseService>();
    // await fs.createOrUpdateUserFromAuth(user);

    // For now navigate to the main app screen
    // Get.offAllNamed(AppRoutes.appNavigationScreen);
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}
