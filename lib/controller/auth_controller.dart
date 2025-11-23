import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _fs = Get.find();

  final userRole = ''.obs;

  int generateRandomPin() {
    final rnd = Random();
    return 100000 + rnd.nextInt(900000);
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String number,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'number': number,
        'floor': 'Ground',
        'role': 'isUser',
        'orderpin': generateRandomPin(),
        'walletBalance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      await _fs.createOrUpdateUserFromAuth(
        firebaseUser: cred.user!,
        userData: userData,
      );
      await _fetchUserRoleAndNavigate();
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Signup failed', e.message ?? 'An error occurred');
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // update fcm token + lastLogin
      final token = await _fs.getDeviceFcmToken();
      if (token != null) await _fs.updateFcmToken(cred.user!.uid, token);
      _fs.startFcmTokenListenerForUser(cred.user!.uid);
      await _fetchUserRoleAndNavigate();
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login failed', e.message ?? 'Unable to login');
      return false;
    }
  }

  Future<void> _fetchUserRoleAndNavigate() async {
    final user = _auth.currentUser;
    if (user == null) {
      userRole.value = 'isUser';
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    final map = await _fs.fetchAppUser(user.uid);
    final role = map!.role;
    userRole.value = role;
    _navigateByRole(role);
  }

  void _navigateByRole(String role) {
    if (role == 'isUser') {
      Get.offAllNamed(AppRoutes.userDashbord);
    } else if (role == 'isStoreKeeper' || role == 'isVendor') {
      Get.offAllNamed(AppRoutes.verndorDashbord);
    } else {
      // fallback
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> logout() async {
    try {
      await _fs.signOut();
      Get.offAllNamed(AppRoutes.phoneLogin);
    } catch (e) {
      Get.snackbar('Logout error', e.toString());
    }
  }
}
