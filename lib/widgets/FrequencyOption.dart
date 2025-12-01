import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class FrequencyOption extends StatelessWidget {
  final String title;
  final String value;
  final String selectedValue;
  final IconData icon;
  final VoidCallback onTap;

  const FrequencyOption({
    super.key,
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedValue == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? appTheme.primaryColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyleHelper.instance.body14BoldPoppins.copyWith(
                  color: isSelected ? appTheme.primaryColor : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 22,
              color: isSelected ? appTheme.primaryColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
