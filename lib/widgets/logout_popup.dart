import 'package:difwa_app/utils/app__text_style.dart';
import 'package:flutter/material.dart';

class YesNoPopup extends StatelessWidget {
  final String title;
  final String description;
  final String noButtonText;
  final String yesButtonText;
  final VoidCallback onNoButtonPressed;
  final VoidCallback onYesButtonPressed;
  final IconData icon;
  final Color iconColor;

  const YesNoPopup({
    super.key,
    required this.title,
    required this.description,
    required this.noButtonText,
    required this.yesButtonText,
    required this.onNoButtonPressed,
    required this.onYesButtonPressed,
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 5, // Adds a floating effect
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      onPressed: onNoButtonPressed,
                      child: Text(noButtonText,
                          style: AppTextStyle.TextWhite16700),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: SizedBox(
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
                      onPressed: onYesButtonPressed,
                      child: Text(yesButtonText,
                          style: AppTextStyle.TextWhite16700),
                    ),
                  ),
                )
              ],
            )
            // Buttons in Column
          ],
        ),
      ),
    );
  }
}
