import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/screens/new/widgets/custom_button.dart' show CustomButton;
import 'package:flutter/material.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/custom_edit_text.dart';
import 'create_account_controller.dart';
class CreateAccountScreen extends GetWidget<CreateAccountController> {
  CreateAccountScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: CustomAppBar(
        height: 56.h,
        leadingIcon: ImageConstant.imgGroup,
        onLeadingPressed: () => Get.back(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 16.h, left: 26.h, right: 26.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.h),
                child: Text(
                  'Create your Account',
                  style: TextStyleHelper.instance.title20BoldPoppins.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                width: SizeUtils.width * 0.84,
                padding: EdgeInsets.only(top: 4.h, left: 2.h),
                child: Text(
                  'Please fill in your details to create your account',
                  style: TextStyleHelper.instance.body14RegularPoppins.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24.h, left: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: TextStyleHelper.instance.body14BoldPoppins
                          .copyWith(height: 1.5),
                    ),
                    CustomEditText(
                      hintText: "Product Experience",
                      controller: controller.nameController,
                      validator: controller.validateName,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(
                        'Email',
                        style: TextStyleHelper.instance.body14BoldPoppins
                            .copyWith(height: 1.5),
                      ),
                    ),
                    CustomEditText(
                      hintText: "Productionexperience@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.emailController,
                      validator: controller.validateEmail,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(
                        'Password',
                        style: TextStyleHelper.instance.body14BoldPoppins
                            .copyWith(height: 1.5),
                      ),
                    ),
                    CustomEditText(
                      hintText: "******************",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      controller: controller.passwordController,
                      validator: controller.validatePassword,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(
                        'Confirm Password',
                        style: TextStyleHelper.instance.body14BoldPoppins
                            .copyWith(height: 1.5),
                      ),
                    ),
                    CustomEditText(
                      hintText: "******************",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      controller: controller.confirmPasswordController,
                      validator: controller.validateConfirmPassword,
                      margin: EdgeInsets.only(top: 6.h),
                    ),
                    Obx(
                      () => CustomButton(
                        text: 'Create an account',
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 66.h),
                        backgroundColor: appTheme.secondyColor,
                        textColor: appTheme.whiteCustom,
                        fontSize: 14.fSize,
                        fontWeight: FontWeight.w700,
                        isEnabled: !controller.isLoading.value,
                        onPressed: () =>
                            controller.onCreateAccountPressed(_formKey), baseTextColor:appTheme.grayLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 14.h, bottom: 54.h),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => controller.onSignInPressed(),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already',
                          style: TextStyleHelper.instance.body14RegularPoppins
                              .copyWith(
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: ' have an account?',
                          style: TextStyleHelper.instance.body14RegularPoppins
                              .copyWith(
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: ' ',
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: 'S',
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(
                                color: appTheme.secondyColor,
                                height: 1.5,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        TextSpan(
                          text: 'ign in',
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
            ],
          ),
        ),
      ),
    );
  }
}
