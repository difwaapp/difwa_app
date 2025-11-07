import 'package:get/get.dart';
import '../../../core/app_export.dart';

/// This class is used in the [LoginScreen] screen with GetX.

class LoginModel {
  // Observable variables for reactive state management
  Rx<String>? email;
  Rx<String>? password;
  Rx<bool>? isRememberMe;

  // Simple constructor with no parameters
  LoginModel({this.email, this.password, this.isRememberMe}) {
    email = email ?? Rx("");
    password = password ?? Rx("");
    isRememberMe = isRememberMe ?? Rx(false);
  }
}
