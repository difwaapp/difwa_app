import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomEditText - A reusable text input field component with support for different input types,
/// validation, and consistent styling across the application.
/// 
/// @param hintText - Placeholder text displayed in the input field
/// @param keyboardType - Type of keyboard to display (email, password, text)
/// @param obscureText - Whether to hide the input text (for passwords)
/// @param validator - Function to validate the input value
/// @param controller - TextEditingController to manage the input value
/// @param margin - Optional margin around the input field
/// @param onTap - Optional callback for tap events (useful for date pickers)
class CustomEditText extends StatelessWidget {
  const CustomEditText({
    super.key,
    this.hintText,
    this.keyboardType,
    this.obscureText,
    this.validator,
    this.controller,
    this.margin,
    this.onTap,
  });

  /// Placeholder text displayed in the input field
  final String? hintText;

  /// Type of keyboard to display for the input
  final TextInputType? keyboardType;

  /// Whether to obscure the text input (for password fields)
  final bool? obscureText;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Controller to manage the text input value
  final TextEditingController? controller;

  /// Optional margin around the input field
  final EdgeInsetsGeometry? margin;

  /// Optional callback for tap events (useful for date pickers)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText ?? false,
        validator: validator,
        onTap: onTap,
        style: TextStyleHelper.instance.body12RegularPoppins,
        decoration: InputDecoration(
          hintText: hintText ?? "",
          hintStyle: TextStyleHelper.instance.body12RegularPoppins,
          contentPadding: EdgeInsets.fromLTRB(22.h, 14.h, 22.h, 14.h),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.gray_700, width: 1.h),
            borderRadius: BorderRadius.circular(0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.gray_700, width: 1.h),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.gray_700, width: 1.h),
            borderRadius: BorderRadius.circular(0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }
}
