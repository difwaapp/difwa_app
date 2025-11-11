import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Upsert user & optionally set fcmToken in the same call.
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
      if (fcmToken != null) updateData['fcmToken'] = fcmToken;
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
        'floor': userData?['floor'] ?? 'defaultFloor',
        'latitude': userData?['latitude'],
        'longitude': userData?['longitude'],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };
      if (fcmToken != null) defaultData['fcmToken'] = fcmToken;
      await userRef.set(defaultData, SetOptions(merge: true));
    }

    // addresses handling (same as before)...
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

  /// Update single token field
  Future<void> updateFcmToken(String uid, String token) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]), // keep history (optional)
      'lastFcmUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Optionally remove old token (call on sign-out)
  Future<void> removeFcmToken(String uid, String token) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.set({
      'fcmTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }

  /// Helper: get current device token
  Future<String?> getDeviceFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('[FirebaseService] getDeviceFcmToken error: $e');
      return null;
    }
  }

  /// Optionally listen for token refresh and update server
  void startFcmTokenListenerForUser(String uid) {
    _messaging.onTokenRefresh.listen((newToken) async {
      print('[FirebaseService] FCM token refreshed: $newToken');
      await updateFcmToken(uid, newToken);
    });
  }


Future<String?> requestAndGetFcmToken() async {
  final messaging = FirebaseMessaging.instance;

  // iOS: request permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Get token
  final token = await messaging.getToken();
  print('[FCM] device token -> $token');
  return token;
}

Future<void> signOut() async {
  final uid = _auth.currentUser?.uid;
  final token = await _messaging.getToken();
  if (uid != null && token != null) {
    await removeFcmToken(uid, token);
  }
  await _auth.signOut();
}


}
