// lib/config/theme/theme_helper.dart
import 'package:flutter/material.dart';

 LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.
class ThemeHelper {
  // The current app theme - you can later switch this string to change theme
  final String _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  final Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': _buildLightColorScheme(),
  };

  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  ThemeData _getThemeData() {
    final colorScheme =
        _supportedColorScheme[_appTheme] ?? _buildLightColorScheme();
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _getThemeColors().scaffoldBg,
      primaryColor: _getThemeColors().primaryColor,
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _getThemeColors().blackColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _getThemeColors().blackColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _getThemeColors().inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _getThemeColors().borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _getThemeColors().primaryColor,
          foregroundColor: _getThemeColors().whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  LightCodeColors themeColor() => _getThemeColors();
  ThemeData themeData() => _getThemeData();

  static ColorScheme _buildLightColorScheme() {
    return ColorScheme.light(
      primary: LightCodeColors().primaryColor,
      onPrimary: LightCodeColors().whiteColor,
      secondary: LightCodeColors().secondyColor,
      onSecondary: LightCodeColors().whiteColor,
      surface: LightCodeColors().cardBg,
      onSurface: LightCodeColors().blackColor,
      // error: LightCodeColors().redColor,
    );
  }
}

/// Centralized app color palette.
///
/// Add or change colors here to affect the whole app.
class LightCodeColors {
  // Primary brand colors
  Color get primaryColor => const Color(0xFF3FBDF1); // bright blue
  Color get primaryColor2 => const Color(0xFF5DCCFB); // lighter blue
  Color get secondyColor => const Color(0xFF1D3757); // deep navy (text / accents)

  // Backgrounds & scaffold
  Color get scaffoldBg => const Color(0xFFF8FAFB); // app scaffold background
  Color get cardBg => const Color(0xFFFFFFFF); // card / sheet background
  Color get surfaceLight => const Color(0xFFF5F8FA);

  // Text colors
  Color get blackColor => const Color(0xFF000000);
  Color get myblack => const Color(0xFF151515);
  Color get whiteColor => const Color(0xFFFFFFFF);
  Color get grayColor => const Color(0xFF615C5C); // main body text gray
  Color get mutedColor => const Color(0xFF9E9E9E); // disabled / muted text
  Color get grayLight => const Color(0xFFCAC2C2);
  Color get grayMedium => const Color(0xFFC5C2C2);
  Color get blackLight => const Color(0xFF333333);
  Color get blackLight2 => const Color(0xFF4B4B4B);

  // Semantic colors
  Color get success => const Color(0xFF28A745);
  Color get warning => const Color(0xFFFFC107);
  Color get danger => const Color(0xFFDC3545);

  // Accent colors
  Color get myGreen => const Color(0xFF13B17A);

  // UI element colors
  Color get borderColor => const Color(0xFFE6E6E6);
  Color get inputFill => const Color(0xFFF5F7FA);
  Color get cardbgcolor => const Color(0xFFF1F7FB);

  // Transparent / utility
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get redCustom => Colors.red;
  Color get greyCustom => Colors.grey;

  // Shades for subtle UI
  Color get gray200 => Colors.grey.shade200;
  Color get gray100 => Colors.grey.shade100;

  // Fallback/legacy names used across project (aliases)
  Color get primayColor => primaryColor; // note spelling variants in code
  Color get primayDark => primaryColor2;

  // some extra tokens used earlier in project
  Color get light_blue_A200 => const Color(0xFF4FC3F7); // used in Splash
  Color get primayColorWithOpacity => primaryColor.withOpacity(0.9);
}
