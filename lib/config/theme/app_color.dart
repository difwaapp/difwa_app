// lib/config/theme/app_colors.dart
// Optional shim so older imports like `import 'package:difwa_app/config/app_color.dart'` keep working.
// Replace usage gradually with `appTheme.*`.

import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class AppColors {
  static Color get primary => appTheme.primaryColor;
  static Color get primary2 => appTheme.primaryColor2;
  static Color get primayColor => appTheme.primayColor; 
  static Color get primayDark => appTheme.primayDark;
  static Color get secondyColor => appTheme.secondyColor;

  static Color get myblack => appTheme.myblack;
  static Color get mywhite => appTheme.whiteColor;
  static Color get blackLight => appTheme.blackLight;
  static Color get blackLight2 => appTheme.blackLight2;
  static Color get grayColor => appTheme.grayColor;
  static Color get grayLight => appTheme.grayLight;
  static Color get grayMedium => appTheme.grayMedium;
  static Color get mutedColor => appTheme.mutedColor;

  static Color get myGreen => appTheme.myGreen;
  static Color get redColor => appTheme.danger;

  static Color get cardbgcolor => appTheme.cardbgcolor;
  static Color get scaffoldBg => appTheme.scaffoldBg;

  // convenience
  static Color get white => appTheme.whiteColor;
  static Color get black => appTheme.blackColor;
}
