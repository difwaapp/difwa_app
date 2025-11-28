import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/phone_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PhoneLoginController extends GetxController {
  final phoneCtrl = TextEditingController();
  final acceptTerms = false.obs;
  final loading = false.obs;
  final googleLoading = false.obs;
  final error = RxnString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _fs = Get.find<FirebaseService>();
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
          loading.value = false;
          try {
            final cred = await _auth.signInWithCredential(credential);
            _onAuthSuccess(cred.user);
          } catch (e) {
            Get.snackbar('Auto sign-in failed', e.toString());
          }
        },
        verificationFailed: (e) {
          loading.value = false;
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
          loading.value = false;
        },
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  // Google Sign-In implementation
  Future<void> signInWithGoogle() async {
    try {
      googleLoading.value = true;
      error.value = null;

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        googleLoading.value = false;
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Handle post sign-in with the same flow as OTP
      await _handlePostSignIn(userCredential.user);
    } catch (e) {
      googleLoading.value = false;
      debugPrint('Google Sign-In error: $e');
      Get.snackbar(
        'Sign-In Failed',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Handle post sign-in (same logic as OTP verification)
  Future<void> _handlePostSignIn(User? user) async {
    if (user == null) {
      googleLoading.value = false;
      Get.snackbar('Error', 'Login failed');
      return;
    }

    try {
      // 1) Get device FCM token
      final fcmToken = await _fs.getDeviceFcmToken();

      // 2) Try to find existing user by email
      final existingDoc = await _fs.findUserByEmail(user.email ?? '');

      if (existingDoc != null) {
        // User exists - update their data
        final docId = existingDoc.id;
        final data = existingDoc.data();
        final role = (data['role'] as String?) ?? 'isUser';
        final existingUid = (data['uid'] as String?) ?? '';

        // Update uid/fcm token / lastLogin
        if (existingUid != user.uid) {
          await _fs.updateExistingUserLogin(
            docId: docId,
            uid: user.uid,
            fcmToken: fcmToken,
          );
        } else {
          await _fs.updateExistingUserLogin(docId: docId, fcmToken: fcmToken);
        }

        googleLoading.value = false;

        // Route by role
        if (role == 'isUser') {
          Get.offAllNamed(AppRoutes.userDashbord);
        } else if (role == 'isStoreKeeper' || role == 'isVendor') {
          Get.offAllNamed(AppRoutes.verndorDashbord);
        } else {
          Get.offAllNamed(AppRoutes.phoneLogin);
        }
        return;
      }

      // 3) No existing user - create new user
      final userData = {
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'number': user.phoneNumber ?? '',
        'role': 'isUser',
        'orderpin': 0,
        'walletBalance': 0,
      };

      await _fs.createNewUserFromAuth(
        firebaseUser: user,
        userData: userData,
        fcmToken: fcmToken,
      );

      // Create default address
      await _saveDefaultAddress(user);

      // Update FCM token and start listener
      if (fcmToken != null) await _fs.updateFcmToken(user.uid, fcmToken);
      _fs.startFcmTokenListenerForUser(user.uid);

      googleLoading.value = false;
      Get.offAllNamed(AppRoutes.userDashbord);
    } catch (e, st) {
      googleLoading.value = false;
      debugPrint('Post sign-in error: $e\n$st');
      Get.snackbar(
        'Error',
        'Failed to save profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.phoneLogin);
    }
  }

  // Create default address using location
  Future<void> _saveDefaultAddress(User user) async {
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
            final house = p.subThoroughfare ?? '';
            final road = p.thoroughfare ?? '';
            final subLocality = p.subLocality ?? '';
            final locality = p.locality ?? '';

            street = [house, road, subLocality]
                .where((s) => s.trim().isNotEmpty)
                .join(', ');
            city = locality;
            state = p.administrativeArea ?? '';
            zip = p.postalCode ?? '';
            country = p.country ?? '';
          }
        } catch (e) {
          debugPrint('Placemark lookup failed: $e');
        }
      }
    } catch (e) {
      debugPrint('Location fetch failed: $e');
    }

    // Build address map
    final addressMap = <String, dynamic>{
      'name': user.displayName ?? '',
      'phone': user.phoneNumber ?? '',
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

    try {
      await _fs.createDefaultAddress(uid: user.uid, address: addressMap);
    } catch (e) {
      debugPrint('Failed to create default address: $e');
    }
  }

  // called when verifyPhone credentials lead to instant sign-in
  Future<void> _onAuthSuccess(User? user) async {
    if (user != null) {
      await _handlePostSignIn(user);
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}
