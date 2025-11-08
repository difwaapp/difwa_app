import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> fetchMerchantId(String userId) async {
    final userIdd = _auth.currentUser?.uid;

    try {
      DocumentSnapshot storeDoc =
          await _firestore.collection('difwa-users').doc(userIdd).get();

      if (!storeDoc.exists) {
        throw Exception("Store document does not exist for this user.");
      }

      return storeDoc['merchantId'];
    } catch (e) {
      throw Exception("Failed to fetch merchantId: $e");
    }
  }

  Future<void> addBottleData(int size, double price, double vacantPrice) async {
    final userId = _auth.currentUser?.uid;
    String? merchantId = await fetchMerchantId(userId.toString());

    final storeId = merchantId;
    if (userId == null) {
      throw Exception("User not logged in.");
    }

    try {
      await _firestore
          .collection('difwa-stores')
          .doc(storeId)
          .collection('difwa-items')
          .add({
        'userId': userId,
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
    final userId = _auth.currentUser?.uid;
    String? merchantId = await fetchMerchantId(userId.toString());

    if (userId == null) {
      yield* Stream.empty();
    }

    yield* _firestore
        .collection('difwa-stores')
        .doc(merchantId)
        .collection('difwa-items')
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
    final userId = _auth.currentUser?.uid;
    final storeId = userId;
    try {
      String? merchantId = await fetchMerchantId(userId.toString());
      await _firestore
          .collection('difwa-stores')
          .doc(merchantId)
          .collection('difwa-items')
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
    final userId = _auth.currentUser?.uid;
    final storeId = userId;
    String? merchantId = await fetchMerchantId(userId.toString());

    try {
      await _firestore
          .collection('difwa-stores')
          .doc(merchantId)
          .collection('difwa-items')
          .doc(docId)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete bottle data: $e");
    }
  }
}
