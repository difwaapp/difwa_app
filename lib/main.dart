import 'package:difwa_app/config/core/utils/size_utils.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
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
