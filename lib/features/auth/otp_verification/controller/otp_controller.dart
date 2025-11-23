// lib/controllers/otp_controller.dart
import 'dart:async';

import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

    if (initialVerificationId != null && initialVerificationId!.isNotEmpty) {
      verificationId.value = initialVerificationId!;
      _resendToken = initialResendToken;
      sent.value = true;
      _startResendTimer();
    } else {
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
    if (ch.length > 1 && ch.length == 6) {
      for (var i = 0; i < 6; i++) code[i] = ch[i];
    } else {
      code[index] = ch.isEmpty ? '' : ch[0];
    }
    code.refresh();

    final joined = code.join();
    if (joined.length == 6 && !joined.contains('')) submitOtp();
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

  // -------------------------
  // Submit OTP
  // -------------------------
  Future<void> submitOtp() async {
    final joined = code.join();
    if (joined.length != 6) {
      Get.dialog(
        const AlertDialog(
          title: Text('Invalid OTP'),
          content: Text('Enter the 6-digit code'),
        ),
      );
      return;
    }

    final verId = verificationId.value;
    if (verId.isEmpty) {
      Get.dialog(
        const AlertDialog(
          title: Text('Error'),
          content: Text('No verification ID. Try resend.'),
        ),
      );
      return;
    }

    loading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: joined,
      );
      final userCred = await _auth.signInWithCredential(credential);
      await _handlePostSignIn(userCred.user);
    } on FirebaseAuthException catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('OTP not valid'),
          content: Text(e.message ?? 'Invalid code'),
        ),
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(title: const Text('Error'), content: Text(e.toString())),
      );
    } finally {
      loading.value = false;
    }
  }

  // -------------------------
  // Post sign-in: upsert user, update tokens, navigate
  // -------------------------
  Future<void> _handlePostSignIn(User? user) async {
    if (user == null) {
      Get.dialog(
        const AlertDialog(title: Text('Error'), content: Text('Login failed')),
      );
      return;
    }

    try {
      // 1) get device token (null-safe)
      final fcmToken = await _fs.getDeviceFcmToken();

      // 2) try to find a user doc by phone
      final existingDoc = await _fs.findUserByPhone(phone);

      if (existingDoc != null) {
        final docId = existingDoc.id;
        final data = existingDoc.data();
        final role = (data['role'] as String?) ?? 'isUser';
        final existingUid = (data['uid'] as String?) ?? '';

        // update uid/fcm token / lastLogin
        if (existingUid != user.uid) {
          await _fs.updateExistingUserLogin(
            docId: docId,
            uid: user.uid,
            fcmToken: fcmToken,
          );
        } else {
          await _fs.updateExistingUserLogin(docId: docId, fcmToken: fcmToken);
        }

        // route by role
        if (role == 'isUser') {
          Get.offAllNamed(AppRoutes.userDashbord);
        } else if (role == 'isStoreKeeper' || role == 'isVendor') {
          Get.offAllNamed(AppRoutes.verndorDashbord);
        } else {
          Get.offAllNamed(AppRoutes.phoneLogin);
        }
        return;
      }

      // 3) if no doc exists, create one for this auth uid with role isUser
      final userData = {
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'number': user.phoneNumber ?? phone,
        'role': 'isUser',
        'orderpin': 0,
        'walletBalance': 0,
      };

      await _fs.createNewUserFromAuth(
        firebaseUser: user,
        userData: userData,
        fcmToken: fcmToken,
      );

      // create default address (attempt to fetch device location; fallback to minimal address)
      await saveDefaultAddress(user);

      // update token and listen for refresh
      if (fcmToken != null) await _fs.updateFcmToken(user.uid, fcmToken);
      _fs.startFcmTokenListenerForUser(user.uid);

      Get.offAllNamed(AppRoutes.userDashbord);
    } catch (e, st) {
      print('Post sign-in error: $e\n$st');
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Failed to save profile: $e',
      );
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
    for (var i = 0; i < 6; i++) code[i] = '';
    code.refresh();

    try {
      loading.value = true;
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final cred = await _auth.signInWithCredential(credential);
            await _handlePostSignIn(cred.user);
          } catch (e) {
            // ignore
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.defaultDialog(
            title: 'Verification failed',
            middleText: e.message ?? 'Unknown error',
          );
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

  // -------------------------
  // Create default address using location if available
  // -------------------------
  Future<void> saveDefaultAddress(User user) async {
    String street = '';
    String city = '';
    String state = '';
    String zip = '';
    String country = '';
    double? lat;
    double? lng;

    try {
      Position? position = await LocationHelper.getCurrentLocation();

      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;

        try {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            // Build street from available pieces
            final house = p.subThoroughfare ?? '';
            final road = p.thoroughfare ?? '';
            final subLocality = p.subLocality ?? '';
            final locality = p.locality ?? '';

            street = [
              house,
              road,
              subLocality,
            ].where((s) => s.trim().isNotEmpty).join(', ');
            city = locality;
            state = p.administrativeArea ?? '';
            zip = p.postalCode ?? '';
            country = p.country ?? '';
          }
        } catch (e) {
          // placemark lookup failed — keep lat/lng and continue
          print('Placemark lookup failed: $e');
        }
      }
    } catch (e) {
      print('Location fetch failed: $e');
    }

    // Build address map (include lat/lng if available)
    final addressMap = <String, dynamic>{
      'name': user.displayName ?? '',
      'phone': user.phoneNumber ?? phone,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'locationType': 'home',
      'floor': 'Ground',
      'isSelected': true,
      'saveAddress': true,
    };

    if (lat != null && lng != null) {
      addressMap['latitude'] = lat;
      addressMap['longitude'] = lng;
    }

    // create default address (FirebaseService.createDefaultAddress should exist)
    try {
      await _fs.createDefaultAddress(uid: user.uid, address: addressMap);
    } catch (e) {
      print('Failed to create default address: $e');
    }
  }
}
