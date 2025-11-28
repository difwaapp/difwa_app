import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<AppUser?> user = Rx<AppUser?>(null);
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _subscribeToUserData(firebaseUser.uid);
      } else {
        _unsubscribeUserData();
      }
    });
  }

  void _subscribeToUserData(String uid) {
    _unsubscribeUserData();
    _userSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        user.value = AppUser.fromMap(
          snapshot.data() as Map<String, dynamic>,
          uid,
        );
      } else {
        user.value = null;
      }
    }, onError: (error) {
      print("Error listening to user data: $error");
    });
  }

  void _unsubscribeUserData() {
    _userSubscription?.cancel();
    _userSubscription = null;
    user.value = null;
  }

  @override
  void onClose() {
    _unsubscribeUserData();
    super.onClose();
  }
}
