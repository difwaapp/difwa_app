import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    required this.width,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isUppercase,
    this.height,
    this.isEnabled, required Color baseTextColor,
  });

  /// The text to display on the button
  final String? text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Width of the button (required for proper layout)
  final double width;

  /// Background color of the button
  final Color? backgroundColor;

  /// Text color of the button
  final Color? textColor;

  /// Font size of the button text
  final double? fontSize;

  /// Font weight of the button text
  final FontWeight? fontWeight;

  /// Internal padding of the button
  final EdgeInsets? padding;

  /// External margin of the button
  final EdgeInsets? margin;

  /// Border radius of the button
  final double? borderRadius;

  /// Whether to transform text to uppercase
  final bool? isUppercase;

  /// Height of the button
  final double? height;

  /// Whether the button is enabled or disabled
  final bool? isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 57.h,
      margin: margin,
      child: ElevatedButton(
        onPressed: (isEnabled ?? true) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF5DCCFB),
          foregroundColor: textColor ?? appTheme.whiteCustom,
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.h),
          ),
          elevation: 0,
          shadowColor: appTheme.transparentCustom,
        ),
        child: Text(
          (isUppercase ?? true) ? (text ?? '').toUpperCase() : (text ?? ''),
          style: TextStyleHelper.instance.body14BoldPoppins.copyWith(
            color: textColor ?? appTheme.whiteCustom,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
