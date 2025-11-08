import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/user_models/user_details_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/widgets/CustomPopup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var verificationId = ''.obs;
  var userRole = ''.obs;

////////// SIGN UP WITH EMAIL ///////////////////////////

  Future<bool> signwithemail(String email, String name, String password,
      String number, bool isLoading, BuildContext context) async {
    try {
      print(email);
      print(name);
      print(password);
      print(number);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user details in Firestore
      await _saveUserDataemail(
          userCredential.user!.uid, email, name, number, 'defaultFloor');
      await _fetchUserRole();
      _navigateToDashboard();
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Oops! Signup Failed ',
          e.message ?? 'An error occurred while signing up');
      return false;
    } catch (e) {
      Get.snackbar('Error2', 'An unexpected error occurred: $e');
      return false;
    }
  }

////////////////////////// LOGIN WITH EMAIL ///////////////////////////
  Future<bool> loginwithemail(String email, String password, bool isLoading,
      BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserRole();
      _navigateToDashboard();
      return true;
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomPopup(
              title: "Oops! Login Failed \n${e.message.toString()}",
              description: e.message.toString(),
              buttonText: "Got It!",
              onButtonPressed: () {
                Get.back();
              },
            );
          });

      return false;
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomPopup(
              title: "Oops! Something Went Wrong",
              description: "An unexpected error occurred: $e",
              buttonText: "Got It!",
              onButtonPressed: () {
                Get.back();
              },
            );
          });

      return false;
    }
  }

////////////////////////// VERIFY USER ///////////////////////////
  Future<void> verifyUserExistenceAndLogin(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fetchUserRole();
      _navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _navigateToLoginPage();
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Incorrect password. Please try again.');
      } else {
        Get.snackbar(
            'Error', e.message ?? 'An error occurred while logging in');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    }
  }

////////////////////////// NAVIGATION ///////////////////////////
  void _navigateToHomePage() {
    Get.offNamed('/home');
  }

  void _navigateToLoginPage() {
    Get.offNamed('/login');
  }

  void _navigateToDashboard() {
    if (userRole.value == 'isUser') {
      Get.offAllNamed(AppRoutes.userbottom);
    } else if (userRole.value == 'isStoreKeeper') {
      Get.offAllNamed(AppRoutes.storebottombar);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  int generateRandomPin() {
    Random random = Random();
    // Generate a random number between 100000 and 999999 (inclusive)
    int pin = 100000 + random.nextInt(900000);
    return pin;
  }

////////////////////////// SAVE USER DETAILS /////////////////////
  Future<void> _saveUserDataemail(String uid, String email, String name,
      String number, String floor) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('difwa-users').doc(uid).get();

    if (!userDoc.exists) {
      await _firestore.collection('difwa-users').doc(uid).set({
        'uid': uid,
        'name': name,
        'number': number,
        'email': email,
        'floor': floor,
        'role': 'isUser',
        'orderpin': generateRandomPin(),
        'walletBalance': 0.0,
      }, SetOptions(merge: true));
    } else {
      await _firestore.collection('difwa-users').doc(uid).update({
        'name': name,
        'number': number,
        'floor': floor,
        'orderpin': generateRandomPin(),
      });
    }
  }

////////////////////////// SAVE USER DETAILS /////////////////////
  Future<void> updateUserDetails(String uid, String email, String name,
      String number, String floor) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('difwa-users').doc(uid).get();

    if (userDoc.exists) {
      // If the user exists, update their details
      await _firestore.collection('difwa-users').doc(uid).update({
        'name': name,
        'number': number,
        'floor': floor,
        'email': email,
        'orderpin': generateRandomPin(),
      });
    } else {
      // If the user does not exist, create a new record
      await _firestore.collection('difwa-users').doc(uid).set({
        'uid': uid,
        'name': name,
        'number': number,
        'email': email,
        'floor': floor,
        'role': 'isUser',
        'walletBalance': 0.0,
        'orderpin': generateRandomPin(),
      }, SetOptions(merge: true));
    }
  }

////////////////////////// FETCH USER ROLE  ///////////////////////
  Future<void> _fetchUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('difwa-users').doc(user.uid).get();
      if (userDoc.exists) {
        userRole.value = userDoc['role'] ?? 'isUser';
      } else {
        userRole.value = 'isUser';
      }
    }
  }

  Future<UserDetailsModel> fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('difwa-users').doc(user.uid).get();
      if (userDoc.exists) {
        print("User data: ${userDoc.data()}");

        var userDetails =
            UserDetailsModel.fromJson(userDoc.data() as Map<String, dynamic>);
        print("UserDetailsModel: $userDetails");

        return userDetails;
      }
    }
    return UserDetailsModel(
        docId: "",
        uid: "",
        name: "",
        number: "",
        email: "",
        floor: "",
        role: "",
        walletBalance: 0.0,
        orderpin: '');
  }

  Future<UserDetailsModel> fetchUserDatabypassUserId(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('difwa-users').doc(userId).get();
    if (userDoc.exists) {
      print("User data: ${userDoc.data()}");

      var userDetails =
          UserDetailsModel.fromJson(userDoc.data() as Map<String, dynamic>);
      print("UserDetailsModel: $userDetails");

      return userDetails;
    }
    return UserDetailsModel(
        docId: "",
        uid: "",
        name: "",
        number: "",
        email: "",
        floor: "",
        role: "",
        walletBalance: 0.0,
        orderpin: '');
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.snackbar('Success', 'Logged out successfully');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', 'Error logging out: $e');
    }
  }
}
