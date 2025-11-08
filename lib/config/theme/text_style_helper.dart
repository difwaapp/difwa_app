import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20BoldPoppinsWhite => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.whiteColor,
  );

  TextStyle get title20BoldPoppinsBlue => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.secondyColor,
  );
  
  TextStyle get title20BoldPoppins => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.secondyColor,
  );

    TextStyle get title16BoldPoppins => TextStyle(
    fontSize: 16.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.secondyColor,
  );
  TextStyle get body14RegularPoppinsWhite => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: appTheme.whiteColor,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularPoppins => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: appTheme.grayColor,
  );

  TextStyle get body14BoldPoppins => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.grayColor,
  );

  TextStyle get body12SemiBoldPoppins => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: appTheme.grayColor,
  );

  TextStyle get body12RegularPoppins => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: appTheme.grayColor,
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextPoppins => TextStyle(fontFamily: 'Poppins');
}
