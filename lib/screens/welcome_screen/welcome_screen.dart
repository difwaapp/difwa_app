import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart'; // your route constants

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // We intentionally avoid an AppBar to allow full-bleed image
      body: Stack(
        children: [
          // Background image (cover)
          Positioned.fill(
            child: Image.asset(
              'assets/icon/water_drop.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Dark gradient overlay (for better contrast)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.12), // top slightly transparent
                    Colors.black.withOpacity(0.55), // middle darker
                    Colors.black.withOpacity(0.75), // bottom darkest for text
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Optional subtle vignette (adds depth)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.3),
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.08),
                    ],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // top spacer to push content toward bottom
                  SizedBox(height: size.height * 0.55),

                  // Title & subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Difwa Water',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Water delivery app',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Buttons (stacked)
                  Column(
                    children: [
                      // Create Account - filled white with black text
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // Get.toNamed(AppRoutes.createAccountScreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'CREATE AN ACCOUNT',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login - transparent with white border
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.login);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white70),
                            backgroundColor: Colors.black.withOpacity(0.05),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Continue as Guest - plain text
                      TextButton(
                        onPressed: () {
                          // Decide where guest goes (home or marketplace)
                          // Get.offAllNamed(AppRoutes.appNavigationScreen);
                        },
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // Bottom safe area spacing
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
