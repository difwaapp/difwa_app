import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../models/create_account_model.dart';

class CreateAccountController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isSuccess = false.obs;
  final createAccountModel = Rx<CreateAccountModel?>(null);

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    createAccountModel.value = CreateAccountModel();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Form submission
  void onCreateAccountPressed(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Update model with form data
      createAccountModel.value?.name!.value = nameController.text;
      createAccountModel.value?.email!.value = emailController.text;
      createAccountModel.value?.password!.value = passwordController.text;

      // Simulate account creation process
      await Future.delayed(Duration(seconds: 2));

      isSuccess.value = true;

      // Show success message
      Get.snackbar('Success', 'Account created successfully!',
          backgroundColor: appTheme.light_blue_300,
          colorText: appTheme.whiteCustom,
          snackPosition: SnackPosition.TOP);

      // Clear form fields
      _clearFormFields();

      // Navigate to login screen
      Get.offNamed(AppRoutes.loginScreen);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account. Please try again.',
          backgroundColor: appTheme.redCustom,
          colorText: appTheme.whiteCustom,
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  void onSignInPressed() {
    Get.toNamed(AppRoutes.loginScreen);
  }

  void _clearFormFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
