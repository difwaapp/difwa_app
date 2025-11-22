import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _fadeText;

  final VendorsController _vendorsController = Get.put(VendorsController());

  VendorModal? vendorData;
  AppUser? usersData;
  late final FirebaseService _fs;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    if (!Get.isRegistered<FirebaseService>()) {
      print('[ProfileScreen] FirebaseService not registered');
      return;
    }
    _fs = Get.find<FirebaseService>();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeText = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      LocationHelper.getCurrentLocation(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offNamed(AppRoutes.useronboarding);
      return;
    }
    await _getUserRole(user.uid);
  }

  Future<void> _getUserRole(String uid) async {
    try {
      final AppUser? user = await _fs.fetchAppUser(uid);

      if (user!.uid == null) {
        Get.offNamed(AppRoutes.useronboarding);
        return;
      }
      if (user.role == 'isUser') {
        Get.offNamed(AppRoutes.userbottom);
      } else if (user.role == 'isStoreKeeper') {
        vendorData = await _vendorsController.fetchStoreData();
        final isVendorVerified = vendorData?.isVerified ?? false;
        print("isverified");
        print(isVendorVerified);

        if (isVendorVerified) {
          Get.offNamed(AppRoutes.storebottombar);
        } else {
          Get.offNamed(AppRoutes.vendor_not_verified);
        }
      } else {
        Get.offNamed(AppRoutes.useronboarding);
      }
    } catch (e) {
      debugPrint("Error getting user role: $e");
      Get.snackbar('Error', 'Failed to retrieve user role');
      Get.offNamed(AppRoutes.useronboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appTheme.primayColor, appTheme.primayColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      "assets/icon/icon_transparent.png",
                      color: appTheme.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _fadeText,
                    child: Column(
                      children: [
                        Text(
                          "Difwa Water",
                          style: TextStyleHelper
                              .instance
                              .title20BoldPoppinsWhite
                              .copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pure Water, Delivered Fresh',
                          style: TextStyleHelper
                              .instance
                              .body14RegularPoppinsWhite
                              .copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeText,
                child: Text(
                  'V1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
