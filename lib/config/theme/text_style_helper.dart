// lib/config/theme/text_style_helper.dart
import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

/// Centralized Poppins-only text style helper.
/// Use `TextStyleHelper.instance` to access styles.
/// All sizes use the `.fSize` extension that exists in your project.
class TextStyleHelper {
  static TextStyleHelper? _instance;
  TextStyleHelper._();
  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // ---------- Headline / Title styles ----------
  TextStyle get title32Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 32.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.blackColor,
      );

  TextStyle get title28Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.blackColor,
      );

  TextStyle get title24Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.blackColor,
      );

        TextStyle get title24BoldPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.secondyColor,
      );

  TextStyle get title20BoldPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.secondyColor,
      );

  TextStyle get title20BoldPoppinsWhite => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.whiteColor,
      );

  TextStyle get title20BoldPoppinsBlue => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.primaryColor,
      );

  TextStyle get title18Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.blackColor,
      );

  TextStyle get title16BoldPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.secondyColor,
      );

  TextStyle get title16SemiBold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        color: appTheme.blackColor,
      );

  // ---------- Body styles ----------
  TextStyle get body18Regular => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.grayColor,
      );

  TextStyle get body16Regular => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.grayColor,
      );

  TextStyle get body14RegularPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.grayColor,
      );

  TextStyle get body14RegularPoppinsWhite => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.whiteColor,
      );

  TextStyle get body14BoldPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.grayColor,
      );

  TextStyle get body12SemiBoldPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.fSize,
        fontWeight: FontWeight.w600,
        color: appTheme.grayColor,
      );

  TextStyle get body12RegularPoppins => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.grayColor,
      );

  // ---------- Caption / small text ----------
  TextStyle get caption12 => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.mutedColor,
      );

  TextStyle get caption11 => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.mutedColor,
      );

  // ---------- White variants ----------
  TextStyle get white16SemiBold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
        color: appTheme.whiteColor,
      );

  TextStyle get white14Regular => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.whiteColor,
      );

  // ---------- Black / primary variants ----------
  TextStyle get primary18Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.primaryColor,
      );

  TextStyle get black14Bold => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.blackColor,
      );

  TextStyle get black16Normal => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        color: appTheme.blackColor,
      );

  // ---------- Utility / custom ----------
  /// Dynamic custom text helper: choose size, weight and color quickly.
  TextStyle customText({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize.fSize,
      fontWeight: fontWeight,
      color: color ?? appTheme.blackColor,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Button text style (primary)
  TextStyle get buttonPrimary => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.whiteColor,
      );

  /// Subtitle style
  TextStyle get subtitle14 => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
        color: appTheme.grayColor,
      );

  // ---------- Backwards-compatible aliases (old names) ----------
  TextStyle get title20BoldPoppinsWhiteAlias => title20BoldPoppinsWhite;
  TextStyle get title20BoldPoppinsBlueAlias => title20BoldPoppinsBlue;
  TextStyle get title20BoldPoppinsAlias => title20BoldPoppins;
  TextStyle get title16BoldPoppinsAlias => title16BoldPoppins;
  TextStyle get body14BoldPoppinsAlias => body14BoldPoppins;
  TextStyle get body14RegularPoppinsAlias => body14RegularPoppins;

  // ---------- Example usage helpers ----------
  /// Use this helper to quickly style ElevatedButton text with primary color
  TextStyle buttonTextForPrimaryBg() => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.fSize,
        fontWeight: FontWeight.w700,
        color: appTheme.whiteColor,
      );
}
