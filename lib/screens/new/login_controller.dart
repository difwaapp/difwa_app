import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'login_model.dart';
class LoginController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Observable variables
  final isLoading = false.obs;
  final isSuccess = false.obs;
  final loginModel = Rx<LoginModel?>(null);

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loginModel.value = LoginModel();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@') || !value.contains('.')) {
      return "Please enter a valid email address";
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // Login button pressed
  void onLoginPressed() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      try {
        // Simulate login process
        await Future.delayed(Duration(seconds: 2));

        // Update model with form data
        loginModel.value?.email!.value = emailController.text;
        loginModel.value?.password!.value = passwordController.text;

        isSuccess.value = true;

        Get.snackbar(
          "Success",
          "Login successful!",
          backgroundColor: appTheme.secondyColor,
          colorText: appTheme.whiteCustom,
          snackPosition: SnackPosition.TOP,
        );

        // Clear form fields
        emailController.clear();
        passwordController.clear();

        // Navigate based on success - since no navigateTo property exists,
        // we'll stay on current screen or navigate to a main screen if available
      } catch (e) {
        Get.snackbar(
          "Error",
          "Login failed. Please try again.",
          backgroundColor: appTheme.redCustom,
          colorText: appTheme.whiteCustom,
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Forgot password pressed
  void onForgotPasswordPressed() {
    Get.snackbar(
      "Forgot Password",
      "Password recovery functionality will be implemented soon.",
      backgroundColor: appTheme.secondyColor,
      colorText: appTheme.whiteCustom,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Sign up pressed
  void onSignUpPressed() {
    Get.toNamed(AppRoutes.signUp);
  }
}
