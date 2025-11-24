import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final FontWeight fontWeight;
  final bool outlined;
  final Color? borderColor;
  final double elevation;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.outlined = false,
    this.borderColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    // Determine colors based on state
    Color effectiveBackgroundColor;
    Color effectiveTextColor;
    Color effectiveBorderColor;
    
    if (outlined) {
      effectiveBackgroundColor = isDisabled 
          ? Colors.grey.shade100 
          : (backgroundColor ?? Colors.transparent);
      effectiveTextColor = isDisabled 
          ? Colors.grey.shade400 
          : (textColor ?? appTheme.primaryColor);
      effectiveBorderColor = isDisabled 
          ? Colors.grey.shade300 
          : (borderColor ?? appTheme.primaryColor);
    } else {
      effectiveBackgroundColor = isDisabled 
          ? Colors.grey.shade300 
          : (backgroundColor ?? appTheme.primaryColor);
      effectiveTextColor = isDisabled 
          ? Colors.grey.shade500 
          : (textColor ?? Colors.white);
      effectiveBorderColor = Colors.transparent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: outlined 
                ? Border.all(color: effectiveBorderColor, width: 1.5) 
                : null,
            boxShadow: !outlined && elevation > 0 && !isDisabled
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? appTheme.primaryColor)
                          .withValues(alpha: 0.3),
                      blurRadius: elevation,
                      offset: Offset(0, elevation / 2),
                    ),
                  ]
                : null,
          ),
          child: Container(
            height: height ?? 56,
            width: width ?? double.infinity,
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(effectiveTextColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: effectiveTextColor,
                            size: fontSize + 4,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            text ?? "Button",
                            style: TextStyle(
                              color: effectiveTextColor,
                              fontSize: fontSize,
                              fontWeight: fontWeight,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

