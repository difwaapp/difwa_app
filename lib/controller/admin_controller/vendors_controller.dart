import 'dart:io';

import 'package:difwa_app/models/vendors_models/vendor_model.dart';
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

  var activevendors = <String, bool>{}.obs;
  Future<String> uploadImage(File imageFile, String fileName,
      {String? subFolder}) async {
    try {
      String path = subFolder != null
          ? 'vendor_images/$subFolder/$fileName'
          : 'vendor_images/$fileName';

      Reference ref = _storage.ref().child(path);
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
    Map<String, String> images,
    VendorModel? newUser,
  ) async {
    try {
      String uid = await _getCurrentUserId();

      // Check if user already has a vendor entry
      String? existingMerchantId = await fetchMerchantId();
      String merchantId;
      bool isUpdate = false;

      if (existingMerchantId != null && existingMerchantId.isNotEmpty) {
        // User already has a vendor entry, reuse the merchantId
        merchantId = existingMerchantId;
        isUpdate = true;
        print(
          "Existing vendor found with merchantId: $merchantId. Updating...",
        );
      } else {
        // New vendor, generate new merchantId
        merchantId = await _generateMerchantId();
        print("New vendor. Generated merchantId: $merchantId");
      }

      if (newUser != null) {
        newUser = newUser.copyWith(uid: uid, merchantId: merchantId);
      } else {
        throw Exception('VendorModal cannot be null');
      }

      await _saveUserStore(newUser, merchantId, isUpdate);
      _showSuccessSnackbar(merchantId, isUpdate: isUpdate);

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
  Future<void> editVendorDetails({VendorModel? modal}) async {
    try {
      if (modal == null) {
        throw Exception("Vendor modal is null.");
      }

      String uid = await _getCurrentUserId();
      Map<String, dynamic> updateData = modal.toFirestoreUpdateMap();
      updateData.removeWhere((key, value) => value == null || value == '');

      print("Updating vendor details for uid: $uid with data: $updateData");

      await FirebaseFirestore.instance
          .collection('vendors')
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
          .collection('vendors')
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
  var vendorStatus = false.obs;
  var balance = 0.0.obs;
  var vendorName = "".obs;
  void fetchStoreDataRealTime(String merchantId) async {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(await fetchMerchantId())
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            if (snapshot.exists) {
              final storeData = snapshot.data() as Map<String, dynamic>;
              vendorStatus.value = storeData['isActive'] ?? false;
              balance.value = storeData['earnings']?.toDouble() ?? 0.0;
              vendorName.value = storeData['vendorName'] ?? "No name";
            }
          }
        });
  }
  Future<VendorModel?> fetchStoreData() async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(await fetchMerchantId())
          .get();

      if (storeDoc.exists) {
        return VendorModel.fromMap(storeDoc.data() as Map<String, dynamic>);
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
  Future<VendorModel?> fetchStoreDataByMerchantId(String merchantId) async {
    try {
      String uid = await _getCurrentUserId();
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(merchantId)
          .get();

      if (storeDoc.exists) {
        return VendorModel.fromMap(storeDoc.data() as Map<String, dynamic>);
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

      String newMerchantId = await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
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
          .collection('vendors')
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
          .collection('vendors')
          .doc(uid)
          .get();

      if (storeDoc.exists) {
        bool currentStatus = storeDoc['isActive'] ?? false;
        bool newStatus = !currentStatus;

        await FirebaseFirestore.instance.collection('vendors').doc(uid).update({
          'isActive': newStatus,
        });

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
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'role': 'isStoreKeeper',
          'merchantId': merchantId,
          'isActive': false,
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
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
  Future<void> _saveUserStore(
    VendorModel newUser,
    String merchantId,
    bool isUpdate,
  ) async {
    try {
      // Get the vendor data map
      Map<String, dynamic> vendorData = newUser.toMap(
        useServerTimestamps: true,
      );

      // Reset verification status for resubmission
      vendorData['isVerified'] = false;
      vendorData['status'] = 'pending';
      vendorData['rejection_reason'] = '';

      if (isUpdate) {
        // Update existing vendor document
        // Use update with merge to preserve fields not in the form
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(merchantId)
            .update(vendorData);

        print("Vendor document updated for merchantId: $merchantId");
      } else {
        // Create new vendor document
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(merchantId)
            .set(vendorData);

        print("New vendor document created for merchantId: $merchantId");
      }
    } catch (e) {
      throw Exception('Error saving user store: ${e.toString()}');
    }
  }

  void _showSuccessSnackbar(String merchantId, {bool isUpdate = false}) {
    Get.snackbar(
      'Success',
      isUpdate
          ? 'Vendor details updated successfully! Merchant ID: $merchantId'
          : 'Signup Successful with Merchant ID: $merchantId',
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

      // Query vendors collection where uid field equals current user's uid
      QuerySnapshot querySnapshot = await _firestore
          .collection('vendors')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No vendor found for uid: $uid");
        return null;
      }

      // Get the first (and should be only) matching document
      DocumentSnapshot vendorDoc = querySnapshot.docs.first;
      String? merchantId = vendorDoc['merchantId'] as String?;

      print("Found merchantId: $merchantId for uid: $uid");
      return merchantId;
    } catch (e) {
      print("Error fetching merchantId: $e");
      throw Exception("Failed to fetch merchantId: $e");
    }
  }

  Future<void> deleteStore() async {
    try {
      String uid = await _getCurrentUserId();
      await FirebaseFirestore.instance.collection('vendors').doc(uid).delete();
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

  Future<void> getIsActiveVendors(List<String> merchantIds) async {
    try {
      for (String id in merchantIds) {
        bool isActive = await getIsActiveStore(id);
        activevendors[id] = isActive;
      }
    } catch (e) {
      print("Error fetching store status: $e");
    }
  }
  Future<void> changeRoleToUser() async {
    try {
      String uid = await _getCurrentUserId();

      // Update user role back to isUser and remove merchantId
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'isUser',
        'merchantId': FieldValue.delete(),
      });

      Get.snackbar(
        'Success',
        'Your role has been changed to User. You can now browse as a regular user.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  GlobalKey<FormState> get formKey => _formKey;
}
