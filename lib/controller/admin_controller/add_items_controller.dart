import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> fetchMerchantId(String uid) async {
    final uidd = _auth.currentUser?.uid;

    try {
      DocumentSnapshot storeDoc =
          await _firestore.collection('users').doc(uidd).get();

      if (!storeDoc.exists) {
        throw Exception("Store document does not exist for this user.");
      }

      return storeDoc['merchantId'];
    } catch (e) {
      throw Exception("Failed to fetch merchantId: $e");
    }
  }

  Future<void> addBottleData(int size, double price, double vacantPrice) async {
    final uid = _auth.currentUser?.uid;
    String? merchantId = await fetchMerchantId(uid.toString());

    final storeId = merchantId;
    if (uid == null) {
      throw Exception("User not logged in.");
    }

    try {
      await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('items')
          .add({
        'uid': uid,
        'size': size,
        'price': price,
        'vacantPrice': vacantPrice,
        'merchantId': merchantId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add bottle data: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> fetchBottleItems() async* {
    final uid = _auth.currentUser?.uid;
    String? merchantId = await fetchMerchantId(uid.toString());

    if (uid == null) {
      yield* Stream.empty();
    }

    yield* _firestore
        .collection('stores')
        .doc(merchantId)
        .collection('items')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'size': doc['size'],
          'price': doc['price'],
          'vacantPrice': doc['vacantPrice'],
          'merchantId': doc['merchantId'],
        };
      }).toList();
    });
  }
  // Update bottle data
  Future<void> updateBottleData(
      String docId, int size, double price, double vacantPrice) async {
    final uid = _auth.currentUser?.uid;
    final storeId = uid;
    try {
      String? merchantId = await fetchMerchantId(uid.toString());
      await _firestore
          .collection('stores')
          .doc(merchantId)
          .collection('items')
          .doc(docId)
          .update({
        'size': size,
        'price': price,
        'vacantPrice': vacantPrice,
        'merchantId': merchantId,
      });
    } catch (e) {
      throw Exception("Failed to update bottle data: $e");
    }
  }

  Future<void> deleteBottleData(String docId) async {
    final uid = _auth.currentUser?.uid;
    final storeId = uid;
    String? merchantId = await fetchMerchantId(uid.toString());

    try {
      await _firestore
          .collection('stores')
          .doc(merchantId)
          .collection('items')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete bottle data: $e");
    }
  }
}
