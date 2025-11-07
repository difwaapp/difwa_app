import 'package:difwa_app/core/app_export.dart';
import 'package:difwa_app/presentation/splash_screen/binding/splash_binding.dart';
import 'package:difwa_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DifwaApp extends StatelessWidget {
  const DifwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'difwa',
      debugShowCheckedModeBanner: false,
      theme: ThemeHelper().themeData(),
      initialBinding: SplashBinding(), // initial dependencies
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
