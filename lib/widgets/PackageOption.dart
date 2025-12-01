import 'package:difwa_app/config/theme/theme_helper.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? appTheme.whiteColor
                    : appTheme.blackColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
