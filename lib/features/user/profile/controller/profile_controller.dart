import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseService _fs = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // form controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final floorCtrl = TextEditingController();
  final orderPinCtrl = TextEditingController();
  final walletCtrl = TextEditingController();

  final isLoading = false.obs;
  final uploading = false.obs;
  final profileImageUrl = RxnString();
  final localImageFile = Rxn<File>();

  final picker = ImagePicker();

  String get uid => _auth.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    try {
      final map = await _fs.getUserMap(uid);
      if (map != null) {
        nameCtrl.text = map['name'] ?? '';
        emailCtrl.text = map['email'] ?? '';
        numberCtrl.text = map['number'] ?? '';
        floorCtrl.text = map['floor'] ?? '';
        orderPinCtrl.text = (map['orderpin'] ?? '').toString();
        walletCtrl.text = (map['walletBalance'] ?? '').toString();
        profileImageUrl.value = map['profileImage'] ?? map['photoUrl'] ?? null;
      }
    } catch (e) {
      print('Error loading user: $e');
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
      if (picked != null) {
        final f = File(picked.path);
        localImageFile.value = f;
      }
    } catch (e) {
      print('Image pick error: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> uploadAndSaveProfile() async {
    // basic validation
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Name cannot be empty');
      return;
    }
    isLoading.value = true;
    try {
      String? uploadedUrl = profileImageUrl.value;
      if (localImageFile.value != null) {
        uploading.value = true;
        uploadedUrl = await _fs.uploadUserProfileImage(uid: uid, file: localImageFile.value!);
        uploading.value = false;
        if (uploadedUrl == null) {
          Get.snackbar('Error', 'Failed to upload image');
          isLoading.value = false;
          return;
        }
      }

      final data = {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'number': numberCtrl.text.trim(),
        'floor': floorCtrl.text.trim(),
        'orderpin': int.tryParse(orderPinCtrl.text.trim()) ?? 0,
        'walletBalance': double.tryParse(walletCtrl.text.trim()) ?? 0,
        'profileImage': uploadedUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _fs.updateUserProfile(uid: uid, data: data);

      // update local state
      profileImageUrl.value = uploadedUrl;
      localImageFile.value = null;

      Get.snackbar('Success', 'Profile updated');
      // Optionally navigate back or refresh other controllers
    } catch (e) {
      print('save profile error: $e');
      Get.defaultDialog(title: 'Error', middleText: 'Failed to save profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> chooseImageDialog() async {
    Get.defaultDialog(
      title: 'Choose image',
      middleText: 'Select image source',
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            pickImage(ImageSource.camera);
          },
          child: const Text('Camera'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            pickImage(ImageSource.gallery);
          },
          child: const Text('Gallery'),
        ),
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
      ],
    );
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    numberCtrl.dispose();
    floorCtrl.dispose();
    orderPinCtrl.dispose();
    walletCtrl.dispose();
    super.onClose();
  }
}
