import 'dart:io';

import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VendorsController extends GetxController {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? imageFile;

  var activeStores = <String, bool>{}.obs;

  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      Reference ref = _storage.ref().child('vendor_images/$fileName');
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();

      Get.snackbar(
        'Upload Success',
        'Image uploaded successfully: $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      Get.snackbar(
        'Upload Error',
        'Failed to upload image: $fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<bool> submitForm2(
      Map<String, String> images, VendorModal? newUser) async {
    try {
      String uid = await _getCurrentUserId();
      String merchantId = await _generateMerchantId();

      if (newUser != null) {
        newUser = newUser.copyWith(
          uid: uid,
          merchantId: merchantId,

        );
      } else {
        throw Exception('VendorModal cannot be null');
      }

      print("Saving user store...");
      await _saveUserStore(newUser, merchantId); 
      print("User store saved.");

      print("Updating user role...");
      await _updateUserRole(uid, merchantId);
      print("User role updated.");

      _showSuccessSnackbar(merchantId);
      return true;
    } catch (e) {
      print("Error in submitForm2: $e");
      _handleError(e);
      return false;
    }
  }

  Future<void> editVendorDetails({VendorModal? modal}) async {
    try {
      if (modal == null) {
        throw Exception("Vendor modal is null.");
      }

      String uid = await _getCurrentUserId();
      Map<String, dynamic> updateData = modal.toMap();
      updateData.removeWhere((key, value) => value == null || value == '');

      print(
          "Updating vendor details for uid: $uid with data: $updateData");

      await FirebaseFirestore.instance
          .collection('stores')
          .doc(await fetchMerchantId())
          .set(updateData, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Vendor details updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Edit vendor error: $e");
      Get.snackbar(
        'Error',
        'Failed to edit vendor: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<void> updateStoreDetails(Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(await fetchMerchantId())
          .update(updates);
      Get.snackbar(
        'Success',
        'Store details updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update store: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  var storeStatus = false.obs;
  var balance = 0.0.obs;
  var vendorName = "".obs;

  void fetchStoreDataRealTime(String merchantId) async {
    FirebaseFirestore.instance
        .collection('stores')
        .doc(await fetchMerchantId())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        if (snapshot.exists) {
          final storeData = snapshot.data() as Map<String, dynamic>;
          storeStatus.value = storeData['isActive'] ?? false;
          balance.value = storeData['earnings']?.toDouble() ?? 0.0;
          vendorName.value = storeData['vendorName'] ?? "No name";
        }
      }
    });
  }

  Future<VendorModal?> fetchStoreData() async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(await fetchMerchantId())
          .get();

      if (storeDoc.exists) {
        return VendorModal.fromMap(storeDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Store with User ID $uid not found');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch store data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<VendorModal?> fetchStoreDataByMerchantId(String merchantId) async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(merchantId)
          .get();

      if (storeDoc.exists) {
        return VendorModal.fromMap(storeDoc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Store with User ID $uid not found');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch store data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<String> _getCurrentUserId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    return currentUser.uid;
  }

  Future<String> _generateMerchantId() async {
    String year = DateTime.now().year.toString().substring(2);
    try {
      DocumentReference counterDoc = FirebaseFirestore.instance
          .collection('order-counters')
          .doc('merchantIdCounter');

      String newMerchantId =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot counterSnapshot = await transaction.get(counterDoc);

        if (!counterSnapshot.exists) {
          transaction.set(counterDoc, {'count': 0});
        }
        int userCount = counterSnapshot.exists ? counterSnapshot['count'] : 0;
        String merchantId =
            'DIFWASTORE$year${(userCount + 1).toString().padLeft(7, '0')}';
        transaction.update(counterDoc, {'count': userCount + 1});
        return merchantId;
      });

      return newMerchantId;
    } catch (e) {
      throw Exception('Error generating merchant ID: ${e.toString()}');
    }
  }

  void setImage(File image) {
    imageFile = image;
  }

  Future<bool> getIsActiveStore(String merchantId) async {
    try {
      QuerySnapshot storeQuerySnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('merchantId', isEqualTo: merchantId)
          .get();

      if (storeQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot storeDoc = storeQuerySnapshot.docs.first;
        return storeDoc['isActive'] ?? false;
      } else {
        throw Exception('Store with Merchant ID $merchantId not found');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch store status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> toggleStoreActiveStatusByCurrentUser() async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(uid)
          .get();

      if (storeDoc.exists) {
        bool currentStatus = storeDoc['isActive'] ?? false;
        bool newStatus = !currentStatus;

        await FirebaseFirestore.instance
            .collection('stores')
            .doc(uid)
            .update({'isActive': newStatus});

        Get.snackbar(
          'Success',
          'Store active status updated to: $newStatus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Store with User ID $uid not found');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle store status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateUserRole(String uid, String merchantId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
          'role': 'isStoreKeeper',
          'merchantId': merchantId,
          'isActive': false,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'role': 'isStoreKeeper',
          'uid': uid,
          'merchantId': merchantId,
          'isActive': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Error updating user role: ${e.toString()}');
    }
  }

  Future<void> _saveUserStore(VendorModal newUser, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(uid)
          .set(newUser.toMap());
    } catch (e) {
      throw Exception('Error saving user store: ${e.toString()}');
    }
  }

  void _showSuccessSnackbar(String merchantId) {
    Get.snackbar(
      'Success',
      'Signup Successful with Merchant ID: $merchantId',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _handleError(dynamic e) {
    print("Error: $e");
    String errorMessage = e is FirebaseAuthException
        ? e.message ?? 'An unknown error occurred'
        : e.toString();
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<String?> fetchMerchantId() async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!storeDoc.exists) {
        return null;
      }

      return storeDoc['merchantId'];
    } catch (e) {
      throw Exception("sefsdsd to fetch merchantId: $e");
    }
  }

  Future<void> deleteStore() async {
    try {
      String uid = await _getCurrentUserId();
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(uid)
          .delete();
      Get.snackbar(
        'Success',
        'Store deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete store: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getIsActiveStores(List<String> merchantIds) async {
    try {
      for (String id in merchantIds) {
        bool isActive = await getIsActiveStore(id);
        activeStores[id] = isActive;
      }
    } catch (e) {
      print("Error fetching store status: $e");
    }
  }

  GlobalKey<FormState> get formKey => _formKey;
}
