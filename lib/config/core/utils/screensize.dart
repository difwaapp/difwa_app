import 'package:flutter/material.dart';

class ScreenType {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isWebsite(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}
