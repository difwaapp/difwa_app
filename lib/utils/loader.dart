import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // Required for ImageFilter

class Loader extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;

  const Loader({
    super.key,
    this.width = 100,
    this.height = 100,
    this.backgroundColor =
        const Color(0x80000000), // Default semi-transparent black background
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Center(
              child: Lottie.asset(
                'assets/lottie/loader.json',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
