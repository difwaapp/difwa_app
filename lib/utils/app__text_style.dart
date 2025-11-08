import 'package:difwa_app/config/app_color.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  // Normal Text Style
  // ignore: constant_identifier_names
  static const TextStyle Text12500 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text12300 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text12400 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text12700 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.primaryColor,
  );

  static const TextStyle Text14300 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text14400 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text14500 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text14700 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle TextRed14700 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.red,
  );
  static const TextStyle Text16600 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.whiteColor,
  );
  static const TextStyle Textblack16600 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.whiteColor,
  );
  static const TextStyle Text20600 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.whiteColor,
  );
  static const TextStyle Text18400 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text18500 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text18300 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text18300LogoColor = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.logoprimary,
  );
  static const TextStyle Text16300LogoColor = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.logoprimary,
  );
  static const TextStyle Text18600 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text28300 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text28600 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.blackColor,
  );

  // Headings
  static const TextStyle Text = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle Text18700 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle TextWhite24700 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle TextBlack24700 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  static const TextStyle TextWhite18700 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle TextWhite16700 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static const TextStyle Text16700 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle Text32600 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle UnderlineText16700 = TextStyle(
    decoration: TextDecoration.underline,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle normalText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ThemeConstants.blackColor,
  );
  static const TextStyle normalHeadingText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle fieldTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle headingText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle subheadingText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeConstants.blackColor,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static TextStyle customText(
      {double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
      Color color = Colors.black87}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
