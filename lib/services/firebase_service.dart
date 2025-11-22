// lib/services/firebase_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get current device token (no permission prompt).
  Future<String?> getDeviceFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('[FirebaseService] getDeviceFcmToken error: $e');
      return null;
    }
  }

  /// Requests iOS permission (if needed) and returns token.
  Future<String?> requestAndGetFcmToken() async {
    final messaging = FirebaseMessaging.instance;
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print(
        '[FirebaseService] FCM permission: ${settings.authorizationStatus}',
      );
      final token = await messaging.getToken();
      print('[FirebaseService] device token -> $token');
      return token;
    } catch (e) {
      print('[FirebaseService] requestAndGetFcmToken error: $e');
      return null;
    }
  }

  /// Update the primary token and optionally keep a history array.
  Future<void> updateFcmToken(String uid, String token) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastFcmUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Remove a token from the stored tokens array (call on sign-out).
  Future<void> removeFcmToken(String uid, String token) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.set({
      'fcmTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }

  /// Listen for token refresh and push new token to Firestore.
  /// Call this after login: startFcmTokenListenerForUser(uid)
  void startFcmTokenListenerForUser(String uid) {
    _messaging.onTokenRefresh.listen((newToken) async {
      print('[FirebaseService] FCM token refreshed: $newToken');
      await updateFcmToken(uid, newToken);
    });
  }

  /// Sign out helper: remove token and sign out from Firebase Auth.
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    final token = await _messaging.getToken();
    if (uid != null && token != null) {
      await removeFcmToken(uid, token);
    }
    await _auth.signOut();
  }

  // -----------------------
  // User & Firestore APIs
  // -----------------------

  /// Generic upsert: create or update user doc. Accepts optional addresses list.
  /// If doc exists -> update lastLogin and merge userData; else create doc.
  Future<void> createOrUpdateUserFromAuth({
    required User firebaseUser,
    Map<String, dynamic>? userData,
    List<Map<String, dynamic>>? addresses,
    String? fcmToken,
  }) async {
    final uid = firebaseUser.uid;
    final userRef = _db.collection('users').doc(uid);

    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final updateData = <String, dynamic>{
        'lastLogin': FieldValue.serverTimestamp(),
      };
      if (userData != null && userData.isNotEmpty) updateData.addAll(userData);
      if (fcmToken != null && fcmToken.isNotEmpty)
        updateData['fcmToken'] = fcmToken;
      await userRef.set(updateData, SetOptions(merge: true));
    } else {
      final defaultData = <String, dynamic>{
        'uid': uid,
        'name': userData?['name'] ?? firebaseUser.displayName ?? '',
        'email': userData?['email'] ?? firebaseUser.email ?? '',
        'number': userData?['number'] ?? firebaseUser.phoneNumber ?? '',
        'role': userData?['role'] ?? 'isUser',
        'orderpin': userData?['orderpin'] ?? 0,
        'walletBalance': userData?['walletBalance'] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };
      if (fcmToken != null && fcmToken.isNotEmpty)
        defaultData['fcmToken'] = fcmToken;
      await userRef.set(defaultData, SetOptions(merge: true));
    }

    // Addresses: write in batch for efficiency
    if (addresses != null && addresses.isNotEmpty) {
      final addressesRef = userRef.collection('address');
      final batch = _db.batch();
      for (final addr in addresses) {
        final docId = (addr['docId'] as String?) ?? addressesRef.doc().id;
        final docRef = addressesRef.doc(docId);
        final addrCopy = Map<String, dynamic>.from(addr);
        addrCopy['docId'] = docId;
        batch.set(docRef, addrCopy, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  /// Alias kept for compatibility - creates or updates user as above.
  Future<void> createNewUserFromAuth({
    required User firebaseUser,
    Map<String, dynamic>? userData,
    List<Map<String, dynamic>>? addresses,
    String? fcmToken,
  }) async {
    return createOrUpdateUserFromAuth(
      firebaseUser: firebaseUser,
      userData: userData,
      addresses: addresses,
      fcmToken: fcmToken,
    );
  }

  /// Find a user document by exact phone number (E.164). Returns doc or null.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findUserByPhone(
    String phone,
  ) async {
    final q = await _db
        .collection('users')
        .where('number', isEqualTo: phone)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first;
  }

  /// Update an existing user doc with lastLogin, fcmToken and optional extra fields.
  Future<void> updateExistingUserLogin({
    required String docId,
    String? uid,
    String? fcmToken,
    Map<String, dynamic>? extraUpdates,
  }) async {
    final updateData = <String, dynamic>{
      'lastLogin': FieldValue.serverTimestamp(),
    };
    if (uid != null && uid.isNotEmpty) updateData['uid'] = uid;
    if (fcmToken != null && fcmToken.isNotEmpty)
      updateData['fcmToken'] = fcmToken;
    if (extraUpdates != null && extraUpdates.isNotEmpty)
      updateData.addAll(extraUpdates);

    await _db
        .collection('users')
        .doc(docId)
        .set(updateData, SetOptions(merge: true));
  }

  /// Fetch AppUser doc and return its map (or null).
  Future<AppUser?> fetchAppUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(snap.data()!, uid);
  }

  // -----------------------
  // Utility helpers
  // -----------------------

  /// Helper: ensures FirebaseService is ready and prints debug state.
  Future<void> debugInfo() async {
    final uid = _auth.currentUser?.uid;
    print('[FirebaseService] authUid=$uid');
    final token = await getDeviceFcmToken();
    print('[FirebaseService] deviceFcmToken=$token');
  }

  // update profile details
  Future<String?> uploadUserProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final ref = _storage.ref().child(
        'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      final task = await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('[FirebaseService] uploadUserProfileImage error: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserMap(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  /// Create a default address for a user (used on first signup).
  /// If `address` is provided it will be merged; otherwise sensible defaults are used.
  Future<void> createDefaultAddress({
    required String uid,
    Map<String, dynamic>? address,
  }) async {
    try {
      final addressesRef = _db
          .collection('users')
          .doc(uid)
          .collection('address');
      final docRef = addressesRef.doc();
      final docId = docRef.id;

      final now = FieldValue.serverTimestamp();

      final Map<String, dynamic> defaultAddr = {
        'docId': docId,
        'uid': uid,
        'name': address?['name'] ?? '',
        'phone': address?['phone'] ?? '',
        'street': address?['street'] ?? '',
        'city': address?['city'] ?? '',
        'state': address?['state'] ?? '',
        'zip': address?['zip'] ?? '',
        'country': address?['country'] ?? '',
        'locationType': address?['locationType'] ?? 'home',
        'floor': address?['floor'] ?? 'Ground',
        'isSelected': address?['isSelected'] ?? true,
        'isDeleted': address?['isDeleted'] ?? false,
        'saveAddress': address?['saveAddress'] ?? true,
        'latitude': address?['latitude'],
        'longitude': address?['longitude'],
        'createdAt': now,
        'updatedAt': now,
      };

      await docRef.set(defaultAddr, SetOptions(merge: true));
    } catch (e) {
      print('[FirebaseService] createDefaultAddress error: $e');
      rethrow;
    }
  }
}
