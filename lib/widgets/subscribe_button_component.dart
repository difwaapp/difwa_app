import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class SubscribeButtonComponent extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final IconData? icon;

  const SubscribeButtonComponent({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text ?? "Subscribe", // Use default text if null
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
