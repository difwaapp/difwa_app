import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/screens/ContactSupportScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'dart:io';

class ServiceNotAvailableScreen extends StatelessWidget {
  const ServiceNotAvailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.mywhite,
      appBar: AppBar(
        backgroundColor:appTheme.blackColor,
        title: const Text("Service Unavailable",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            )),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display Image from URL
              Image.network(
                'https://img.freepik.com/free-vector/503-error-service-unavailable-concept-illustration_114360-1937.jpg?semt=ais_hybrid&w=740',
                height: screenSize.height * 0.35,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                "Service Not Available",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color:appTheme.blackColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We're sorry, but currently, our service is not available in your area. "
                "Please check back later or contact support for more information.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Go Back",
                height: 50,
                width: double.infinity,
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // Exits the app on Android
                  } else if (Platform.isIOS) {
                    exit(0); // Exits the app on iOS
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Contact Support",
                height: 50,
                width: double.infinity,
                baseTextColor: Colors.white,
                backgroundColor: Colors.orange,
                onPressed: () {
                  Get.to(() => const ContactSupportScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
