import 'package:difwa_app/config/app_color.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final double borderRadius;
  final bool left;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color baseTextColor;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.logoprimary,
    this.textColor = Colors.white,
    this.icon,
    this.borderRadius = 30.0,
    this.left = false,
    this.width,
    this.height,
    this.borderColor,
    this.baseTextColor = Colors.black,
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? 120;
    final buttonHeight = height ?? 40;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Top Left Image
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(10),
        //     child: Image.asset(
        //       'assets/button/blbg.png',

        //     ),
        //   ),
        // ),

        // Bottom Right Image
        // Positioned(
        //   top: 0,
        //   right: 0,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(10),
        //     child: Image.asset(
        //       'assets/button/trbg.png',

        //     ),
        //   ),
        // ),

        // Button
        SizedBox(
          // decoration: BoxDecoration(
          // color: AppColors.logoprimary, // Apply gradient here
          //   // border: Border.all(color: borderColor ?? AppColors.buttonbgColor),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoprimary,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(left ? borderRadius : 30),
                  bottomLeft: Radius.circular(left ? borderRadius : 30),
                  topRight: Radius.circular(left ? borderRadius : 30),
                  bottomRight: Radius.circular(left ? borderRadius : 30),
                ),
                side: borderColor != null
                    ? BorderSide(color: borderColor!)
                    : BorderSide.none,
              ),
              elevation: 0,
            ),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.logoprimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (left && icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            AppColors.mywhite, // Ensures contrast with gradient
                      ),
                    ),
                    if (!left && icon != null) ...[
                      const SizedBox(width: 8),
                      icon!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
