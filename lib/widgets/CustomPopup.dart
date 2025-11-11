import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final IconData icon;
  final Color iconColor;

  const CustomPopup({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
    this.icon = Icons.info_outline, // Default icon
    this.iconColor = Colors.blue, // Default icon color
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon at the Top
            CircleAvatar(
              radius: 30,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 16),

            // Title
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.body14BoldPoppins.copyWith(color: Colors.red)),
            const SizedBox(height: 10),

            // Description
            Text(description,
                textAlign: TextAlign.center,
                style:  TextStyleHelper.instance.body14BoldPoppins.copyWith(color: Colors.red)),
            const SizedBox(height: 20),

            // Animated Button with Ripple Effect
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 5, // Adds a floating effect
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                onPressed: onButtonPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
