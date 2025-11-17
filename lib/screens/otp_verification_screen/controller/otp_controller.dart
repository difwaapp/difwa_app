// lib/controllers/otp_controller.dart
import 'dart:async';

import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class OtpController extends GetxController {
  final String phone; // expected E.164 normalized phone (e.g. +9198....)
  final String? initialVerificationId;
  final int? initialResendToken;

  OtpController({
    required this.phone,
    this.initialVerificationId,
    this.initialResendToken,
  });

  // Firebase + service
  final _auth = FirebaseAuth.instance;
  final FirebaseService _fs = Get.find();

  // UI / state
  final code = List<String>.filled(6, '').obs;
  final verificationId = ''.obs;
  final loading = false.obs;
  final error = RxnString();
  final sent = false.obs;
  final canResend = false.obs;
  final resendSeconds = 60.obs;

  Timer? _resendTimer;
  int? _resendToken;

  @override
  void onInit() {
    super.onInit();

    // If verification info was passed from previous screen, use it.
    if (initialVerificationId != null && initialVerificationId!.isNotEmpty) {
      verificationId.value = initialVerificationId!;
      _resendToken = initialResendToken;
      sent.value = true;
      _startResendTimer();
    } else {
      // Start verification flow here if it wasn't started already.
      _startPhoneVerification();
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  // -------------------------
  // Input helpers
  // -------------------------
  void updateDigit(int index, String value) {
    if (index < 0 || index >= 6) return;
    final ch = value.trim();
    // handle paste (if user pasted whole code into a single box)
    if (ch.length > 1 && ch.length == 6) {
      for (var i = 0; i < 6; i++) {
        code[i] = ch[i];
      }
    } else {
      code[index] = ch.isEmpty ? '' : ch[0];
    }
    code.refresh();

    final joined = code.join();
    if (joined.length == 6 && !joined.contains('')) {
      submitOtp();
    }
  }

  // -------------------------
  // Phone verification flow
  // -------------------------
  void _startPhoneVerification() async {
    error.value = null;
    loading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android instant verification: try signing in
          try {
            loading.value = true;
            final userCred = await _auth.signInWithCredential(credential);
            await _handlePostSignIn(userCred.user);
          } catch (e) {
            error.value = 'Auto sign-in failed: $e';
            Get.defaultDialog(title: 'Error', middleText: error.value ?? 'Auto sign-in failed');
          } finally {
            loading.value = false;
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          loading.value = false;
          error.value = e.message ?? 'Verification failed';
          Get.defaultDialog(title: 'Verification failed', middleText: error.value ?? 'Unknown error');
        },
        codeSent: (String verId, int? resendToken) {
          loading.value = false;
          verificationId.value = verId;
          _resendToken = resendToken;
          sent.value = true;
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Called when auto-retrieval times out. Keep verificationId for manual entry.
          verificationId.value = verId;
        },
      );
    } catch (e) {
      loading.value = false;
      error.value = e.toString();
      Get.defaultDialog(title: 'Error', middleText: error.value ?? 'Unknown error');
    }
  }

  // -------------------------
  // Submit OTP
  // -------------------------
  Future<void> submitOtp() async {
    final joined = code.join();
    if (joined.length != 6) {
      Get.dialog(AlertDialog(title: const Text('Invalid OTP'), content: const Text('Enter the 6-digit code')));
      return;
    }

    final verId = verificationId.value;
    if (verId.isEmpty) {
      Get.dialog(AlertDialog(title: const Text('Error'), content: const Text('No verification ID. Try resend.')));
      return;
    }

    loading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verId, smsCode: joined);
      final userCred = await _auth.signInWithCredential(credential);
      await _handlePostSignIn(userCred.user);
    } on FirebaseAuthException catch (e) {
      Get.dialog(AlertDialog(title: const Text('OTP not valid'), content: Text(e.message ?? 'Invalid code')));
    } catch (e) {
      Get.dialog(AlertDialog(title: const Text('Error'), content: Text(e.toString())));
    } finally {
      loading.value = false;
    }
  }

  // -------------------------
  // Post sign-in: upsert user, update tokens, navigate
  // -------------------------
  Future<void> _handlePostSignIn(User? user) async {
    if (user == null) {
      Get.dialog(AlertDialog(title: const Text('Error'), content: const Text('Login failed')));
      return;
    }

    try {
      // 1) get device token (null-safe)
      final fcmToken = await _fs.getDeviceFcmToken();

      // 2) try to find a user doc by phone (ensure phone used here matches stored format)
      final existingDoc = await _fs.findUserByPhone(phone);

      if (existingDoc != null) {
        final docId = existingDoc.id;
        final data = existingDoc.data();
        final role = (data['role'] as String?) ?? 'isUser';
        final existingUid = (data['uid'] as String?) ?? '';

        // update uid/fcm token / lastLogin
        if (existingUid != user.uid) {
          await _fs.updateExistingUserLogin(docId: docId, uid: user.uid, fcmToken: fcmToken);
        } else {
          await _fs.updateExistingUserLogin(docId: docId, fcmToken: fcmToken);
        }

        // route by role
        if (role == 'isUser') {
          Get.offAllNamed(AppRoutes.userbottom);
        } else if (role == 'isStoreKeeper' || role == 'isVendor') {
          Get.offAllNamed(AppRoutes.storebottombar);
        } else {
          // safe fallback
          Get.offAllNamed(AppRoutes.phoneLogin);
        }
        // done
        return;
      }

      // 3) if no doc exists, create one for this auth uid with role isUser
      final userData = {
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'number': user.phoneNumber ?? phone,
        'role': 'isUser',
        'floor': 'defaultFloor',
        'orderpin': 0,
        'walletBalance': 0,
      };

      await _fs.createNewUserFromAuth(firebaseUser: user, userData: userData, fcmToken: fcmToken);

      // update token and listen for refresh
      if (fcmToken != null) await _fs.updateFcmToken(user.uid, fcmToken);
      _fs.startFcmTokenListenerForUser(user.uid);

      // final navigation for new user
      Get.offAllNamed(AppRoutes.userbottom);
    } catch (e, st) {
      print('Post sign-in error: $e\n$st');
      Get.defaultDialog(title: 'Error', middleText: 'Failed to save profile: $e');
      // fallback: allow user to retry phone login
      Get.offAllNamed(AppRoutes.phoneLogin);
    }
  }

  // -------------------------
  // Resend logic
  // -------------------------
  void _startResendTimer() {
    resendSeconds.value = 60;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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

    // clear UI fields
    for (var i = 0; i < 6; i++) code[i] = '';
    code.refresh();

    // call verifyPhoneNumber again to resend; use stored token if available
    try {
      loading.value = true;
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // auto sign-in if possible
          try {
            final cred = await _auth.signInWithCredential(credential);
            await _handlePostSignIn(cred.user);
          } catch (e) {
            // ignore
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.defaultDialog(title: 'Verification failed', middleText: e.message ?? 'Unknown error');
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          _resendToken = resendToken;
          sent.value = true;
          _startResendTimer();
          Get.snackbar('OTP Sent', 'A new code has been sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      Get.defaultDialog(title: 'Error', middleText: e.toString());
    } finally {
      loading.value = false;
    }
  }
}
