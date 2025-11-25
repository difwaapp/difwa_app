import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  final VendorsController _vendorsController = Get.put(VendorsController());
  VendorModel? vendorData;
  AppUser? usersData;
  late final FirebaseService _fs;

  @override
  void initState() {
    super.initState();
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initializeAnimations();
    _loadInitialData();
    if (!Get.isRegistered<FirebaseService>()) {
      debugPrint('[SplashScreen] FirebaseService not registered');
      return;
    }
    _fs = Get.find<FirebaseService>();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      LocationHelper.getCurrentLocation(),
      Future.delayed(const Duration(milliseconds: 200)),
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

      if (user == null) {
        Get.offNamed(AppRoutes.useronboarding);
        return;
      }
      if (user.role == 'isUser') {
        Get.offNamed(AppRoutes.userDashbord);
      } else if (user.role == 'isStoreKeeper') {
        vendorData = await _vendorsController.fetchStoreData();
        final isVendorVerified = vendorData?.isVerified ?? false;
        debugPrint("Vendor verified: $isVendorVerified");

        if (isVendorVerified) {
          Get.offNamed(AppRoutes.verndorDashbord);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Image.asset(
                          "assets/icon/icon_transparent.png",
                          width: 120,
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeIn,
                      child: AnimatedBuilder(
                        animation: _slideUp,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            const Text(
                              "Difwa Water",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pure Water, Delivered Fresh',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            // Feature highlights
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Column(
                                children: [
                                  _buildFeatureItem(
                                    Icons.water_drop,
                                    'Premium Quality',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureItem(
                                    Icons.schedule,
                                    'Flexible Delivery',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureItem(Icons.eco, 'Eco-Friendly'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Version at bottom
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
