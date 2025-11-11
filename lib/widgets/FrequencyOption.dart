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
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? appTheme.whiteColor
                  :appTheme.blackColor,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: isSelected
                      ? TextStyleHelper.instance.body14BoldPoppins
                      :  TextStyleHelper.instance.body14BoldPoppins),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 22,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
