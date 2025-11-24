import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../../../routes/app_routes.dart';

class CongratulationsPage extends StatefulWidget {
  const CongratulationsPage({super.key});

  @override
  _CongratulationsPageState createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _confettiController.play(); // Start Confetti Animation
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoutes.userDashbord);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                emissionFrequency: 0.02,
                numberOfParticles: 10,
                gravity: 0.3,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow
                ],
              ),
            ),

            /// 🎬 Lottie Animation (Success Animation)
            Positioned(
              top: 100,
              child: Lottie.asset(
                'assets/success.json', // Add this file in assets
                width: 200,
                repeat: false,
              ),
            ),

            /// 🎊 Animated Text
            Positioned(
              top: 320,
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Payment Successful!',
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),

            /// ✅ Success Message
            Positioned(
              top: 380,
              child: Text(
                'Thank you for your order!',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),

            /// 🚀 Continue Button
            Positioned(
              top: 425,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:appTheme.whiteColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Get.offAllNamed(AppRoutes.userDashbord);
                },
                child:  Text(
                  "Continue",
                  style: TextStyleHelper.instance.primary18Bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
