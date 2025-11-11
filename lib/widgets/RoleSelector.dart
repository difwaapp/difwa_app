import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:flutter/material.dart';

class LocationTypeSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final void Function(String) onChanged;

  const LocationTypeSelector({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((role) {
        final isSelected = selected == role;
        return GestureDetector(
          onTap: () => onChanged(role),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.mywhite,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle,
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                ),
                const SizedBox(width: 10),
                Text(
                  _capitalize(role),
                  style: isSelected
                      ? TextStyleHelper.instance.body14BoldPoppins
                      : TextStyleHelper.instance.black14Bold,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}
