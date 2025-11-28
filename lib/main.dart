import 'package:difwa_app/config/core/utils/size_utils.dart';
import 'package:difwa_app/controller/user_controller.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/user/profile/binding/profile_binding.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode('en');
  await FirebaseAppCheck.instance.activate(         // production on iOS

    androidProvider: AndroidProvider.playIntegrity,
    // iosProvider: AppleProvider.deviceCheck, // for iOS
    // webRecaptchaSiteKey: 'YOUR_KEY_IF_WEB'
  );

  Get.put<FirebaseService>(FirebaseService(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);
  // Optional debug info
  final fs = Get.find<FirebaseService>();
  fs.debugInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Difwa Water',
      theme: ThemeHelper().themeData(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: false,
      initialBinding: ProfileBinding(),
      builder: (context, child) {
        // Initialize SizeUtils once
        try {
          SizeUtils().init(context);
        } catch (e) {
          // ignore - init is idempotent and safe
          print('[SizeUtils] init error: $e');
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
