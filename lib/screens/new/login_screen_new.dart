import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/core/utils/image_constant.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/screens/new/login_controller.dart';
import 'package:difwa_app/screens/new/widgets/custom_app_bar.dart';
import 'package:difwa_app/screens/new/widgets/custom_button.dart';
import 'package:difwa_app/screens/new/widgets/custom_edit_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class LoginScreenNew extends GetWidget<LoginController> {
  const LoginScreenNew({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: CustomAppBar(
        leadingIcon: ImageConstant.imgGroup,
        onLeadingPressed: () => Get.back(),
      ),
      body: Form(
        key: controller.formKey,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 14.h,
            right: 26.h,
            bottom: 14.h,
            left: 26.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 2.h),
                child: Text(
                  "Welcome Back!",
                  style: TextStyleHelper.instance.title20BoldPoppins.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 6.h, left: 2.h),
                child: Text(
                  "Please fill in your email password to login to your account.",
                  style: TextStyleHelper.instance.body14RegularPoppins.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 36.h, left: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: TextStyleHelper.instance.body14BoldPoppins
                          .copyWith(height: 1.5),
                    ),
                    CustomEditText(
                      hintText: "Productionexperience@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.emailController,
                      validator: controller.validateEmail,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18.h, left: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password",
                      style: TextStyleHelper.instance.body14BoldPoppins
                          .copyWith(height: 1.5),
                    ),
                    CustomEditText(
                      hintText: "******************",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      controller: controller.passwordController,
                      validator: controller.validatePassword,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 22.h),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: controller.onForgotPasswordPressed,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyleHelper.instance.body12SemiBoldPoppins
                              .copyWith(height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Obx(
                () => CustomButton(
                  text: 'Login',
                  width: double.infinity,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.onLoginPressed, baseTextColor: appTheme.grayLight,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16.h),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: controller.onSignUpPressed,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "D",
                          style: TextStyleHelper.instance.body14RegularPoppins
                              .copyWith(
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: "on't  have an account?",
                          style: TextStyleHelper.instance.body14RegularPoppins
                              .copyWith(
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: " ",
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(
                                color: appTheme.secondyColor,
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: "S",
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(
                                color: appTheme.secondyColor,
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: "ign UP",
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(
                                color: appTheme.secondyColor,
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
