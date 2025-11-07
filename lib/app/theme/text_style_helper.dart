import 'package:flutter/material.dart';
import '../../core/app_export.dart';

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

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title20BoldPoppins => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.light_blue_300,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularPoppins => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: appTheme.gray_700,
  );

  TextStyle get body14BoldPoppins => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: appTheme.gray_700,
  );

  TextStyle get body12SemiBoldPoppins => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: appTheme.gray_700,
  );

  TextStyle get body12RegularPoppins => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: appTheme.gray_700,
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextPoppins => TextStyle(fontFamily: 'Poppins');
}
