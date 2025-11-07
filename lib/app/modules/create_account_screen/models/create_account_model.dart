import 'package:get/get.dart';
import '../../../../core/app_export.dart';

/// This class is used in the [CreateAccountScreen] screen with GetX.

class CreateAccountModel {
  // Observable variables for reactive state management
  Rx<String>? name;
  Rx<String>? email;
  Rx<String>? password;
  Rx<String>? confirmPassword;
  Rx<bool>? isFormValid;

  // Simple constructor with no parameters
  CreateAccountModel({
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.isFormValid,
  }) {
    name = name ?? Rx("");
    email = email ?? Rx("");
    password = password ?? Rx("");
    confirmPassword = confirmPassword ?? Rx("");
    isFormValid = isFormValid ?? Rx(false);
  }
}
