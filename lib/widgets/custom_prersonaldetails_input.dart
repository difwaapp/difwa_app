import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class UserDetailInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final IconData? icon;

  const UserDetailInputField({super.key, 
    required this.label,
    this.controller,
    this.keyboardType,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: appTheme.secondyColor),
              if (icon != null) SizedBox(width: 10),
              Text(label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 35),
            child: Text(
              controller?.text ?? '', // Display controller text if available
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
        ],
      ),
    );
  }
}
