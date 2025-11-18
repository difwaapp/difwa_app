import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _db;

  WalletService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol => _db.collection('users').withConverter(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (map, _) => map,
      );

  CollectionReference<Map<String, dynamic>> get _historyCol => _db.collection('wallet_history');

  /// Atomically add amount to user's wallet and create a history record.
  /// amount must be positive. Returns the new balance.
  Future<double> creditWallet({
    required String uid,
    required double amount,
    String? reason,
    String? orderId,
    Map<String, dynamic>? meta,
  }) async {
    assert(amount > 0, 'amount must be > 0');

    final userRef = _db.collection('users').doc(uid);
    final historyRef = _historyCol.doc();

    return _db.runTransaction<double>((tx) async {
      final snapshot = await tx.get(userRef);
      double current = 0.0;
      if (snapshot.exists) {
        final m = snapshot.data()!;
        final w = m['walletBalance'];
        if (w != null) current = (w as num).toDouble();
      } else {
        // create baseline user doc if you prefer
        tx.set(userRef, {'walletBalance': 0.0}, SetOptions(merge: true));
      }

      final newBalance = current + amount;

      tx.set(userRef, {
        'walletBalance': newBalance,
        'lastWalletUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'amountStatus': 'Credited',
        'reason': reason ?? 'Top-up',
        'orderId': orderId ?? '',
        'meta': meta ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });

      return newBalance;
    });
  }

  /// Atomically deduct amount from wallet (if enough funds) and create a history record.
  /// Throws an Exception if insufficient funds.
  Future<double> debitWallet({
    required String uid,
    required double amount,
    String? reason,
    String? orderId,
    Map<String, dynamic>? meta,
  }) async {
    assert(amount > 0, 'amount must be > 0');

    final userRef = _db.collection('users').doc(uid);
    final historyRef = _historyCol.doc();

    return _db.runTransaction<double>((tx) async {
      final snapshot = await tx.get(userRef);
      double current = 0.0;
      if (snapshot.exists) {
        final m = snapshot.data()!;
        final w = m['walletBalance'];
        if (w != null) current = (w as num).toDouble();
      } else {
        throw Exception('User not found');
      }

      if (current < amount) {
        throw Exception('Insufficient wallet balance');
      }

      final newBalance = current - amount;

      tx.set(userRef, {
        'walletBalance': newBalance,
        'lastWalletUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(historyRef, {
        'uid': uid,
        'amount': amount,
        'amountStatus': 'Debited',
        'reason': reason ?? 'Payment',
        'orderId': orderId ?? '',
        'meta': meta ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });

      return newBalance;
    });
  }

  /// Create an arbitrary history record without touching balance (for refunds/manual logs).
  Future<DocumentReference<Map<String, dynamic>>> createHistoryRecord({
    required String uid,
    required double amount,
    required String amountStatus, // 'Credited' or 'Debited'
    String? reason,
    Map<String, dynamic>? meta,
    String? orderId,
  }) async {
    final ref = _historyCol.doc();
    await ref.set({
      'uid': uid,
      'amount': amount,
      'amountStatus': amountStatus,
      'reason': reason ?? '',
      'orderId': orderId ?? '',
      'meta': meta ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
    return ref;
  }

  /// Stream user's wallet balance document (live updates).
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Query stream for wallet history for user (paged by limit).
  Stream<List<Map<String, dynamic>>> historyStream(String uid, {int limit = 50}) {
    return _historyCol
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Paginated fetch of history (for "See All" screen).
  /// lastSnapshot can be the last DocumentSnapshot from previous batch.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchHistoryPage({
    required String uid,
    int pageSize = 20,
    QueryDocumentSnapshot<Map<String, dynamic>>? lastSnapshot,
  }) async {
    Query<Map<String, dynamic>> q = _historyCol.where('uid', isEqualTo: uid).orderBy('timestamp', descending: true).limit(pageSize);
    if (lastSnapshot != null) q = q.startAfterDocument(lastSnapshot);
    final snap = await q.get();
    return snap.docs;
  }
}
