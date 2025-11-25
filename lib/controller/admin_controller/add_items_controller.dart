import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/water_bottle_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Future<String> resolveMerchantId({String? forUid}) async {
    final uid = forUid ?? currentUid;
    if (uid == null) throw Exception('User not logged in');
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User document not found');
    final mid = doc.data()?['merchantId'];
    if (mid == null || mid.toString().isEmpty) {
      throw Exception('merchantId not set for this user');
    }
    return mid.toString();
  }

  Future<String> _uploadImage(File file, String merchantId) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref().child(
      'vendors/$merchantId/items/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  /// Add item (water bottle). Returns created document id.
  Future<String> addItem({
    required String name,
    String? description,
    required int size,
    required double price,
    required double emptyBottlePrice,
    File? imageFile,
    List<File>? extraImageFiles,
    String category = 'Water Bottle',
    bool inStock = true,
    int quantity = 0,
    double? latitude,
    double? longitude,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('User not logged in');

    final merchantId = await resolveMerchantId(forUid: uid);

    String? mainImage;
    final List<String> images = [];

    if (imageFile != null) {
      mainImage = await _uploadImage(imageFile, merchantId);
      images.add(mainImage);
    }

    if (extraImageFiles != null && extraImageFiles.isNotEmpty) {
      for (final f in extraImageFiles) {
        final url = await _uploadImage(f, merchantId);
        images.add(url);
      }
    }

    final docRef = await _firestore
        .collection('vendors')
        .doc(merchantId)
        .collection('items')
        .add({
          'name': name,
          'description': description ?? '',
          'size': size,
          'price': price,
          'emptyBottlePrice': emptyBottlePrice,
          'imageUrl': mainImage ?? '',
          'images': images,
          'merchantId': merchantId,
          'uid': uid,
          'category': category,
          'inStock': inStock,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
        });

    return docRef.id;
  }

  /// Update an existing item.
  Future<void> updateItem({
    required String docId,
    required int size,
    required double price,
    required double emptyBottlePrice,
    String? name,
    String? description,
    File? newImageFile,
    List<File>? newExtraImages,
    String? category,
    bool? inStock,
    int? quantity,
    double? latitude,
    double? longitude,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('User not logged in');

    final merchantId = await resolveMerchantId(forUid: uid);

    final Map<String, dynamic> updates = {
      'size': size,
      'price': price,
      'emptyBottlePrice': emptyBottlePrice,
      'merchantId': merchantId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (inStock != null) updates['inStock'] = inStock;
    if (quantity != null) updates['quantity'] = quantity;

    // handle new images (if any)
    List<String> newUrls = [];
    if (newImageFile != null) {
      final url = await _uploadImage(newImageFile, merchantId);
      updates['imageUrl'] = url;
      newUrls.add(url);
    }
    if (newExtraImages != null && newExtraImages.isNotEmpty) {
      for (final f in newExtraImages) {
        final url = await _uploadImage(f, merchantId);
        newUrls.add(url);
      }
      // merge with existing images on server (safe-merge)
      final docRef = _firestore
          .collection('vendors')
          .doc(merchantId)
          .collection('items')
          .doc(docId);
      final snap = await docRef.get();
      final existingImages =
          (snap.data()?['images'] as List<dynamic>?)?.cast<String>() ?? [];
      updates['images'] = [...existingImages, ...newUrls];
    }

    await _firestore
        .collection('vendors')
        .doc(merchantId)
        .collection('items')
        .doc(docId)
        .set(updates, SetOptions(merge: true));
  }

  Future<void> deleteItem(String docId) async {
    final uid = currentUid;
    if (uid == null) throw Exception('User not logged in');
    final merchantId = await resolveMerchantId(forUid: uid);
    await _firestore
        .collection('vendors')
        .doc(merchantId)
        .collection('items')
        .doc(docId)
        .delete();
  }

  /// Stream of WaterBottleModel for current merchant (safe casting, no mutation)
  Stream<List<WaterBottleModel>> itemsStream() async* {
    final uid = currentUid;
    if (uid == null) {
      yield [];
      return;
    }
    final merchantId = await resolveMerchantId(forUid: uid);
    yield* _firestore
        .collection('vendors')
        .doc(merchantId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((d) {
            final data = d.data();
            // merge docId into a fresh Map so we don't try to mutate Firestore's internal map
            final mapWithId = <String, dynamic>{...data, 'docId': d.id};
            return WaterBottleModel.fromMap(mapWithId, d.id);
          }).toList();
        });
  }
}
