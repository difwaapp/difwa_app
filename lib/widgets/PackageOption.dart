import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';

class PackageOption extends StatelessWidget {
  final String title;
  final int index;
  final int? selectedIndex;
  final VoidCallback onTap;

  const PackageOption({
    super.key,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                : [],
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? ThemeConstants.whiteColor
                      : ThemeConstants.blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
