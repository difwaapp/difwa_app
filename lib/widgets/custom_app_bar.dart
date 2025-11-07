import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// CustomAppBar - A reusable app bar component with customizable leading icon and standard AppBar features
/// 
/// This component provides a flexible AppBar implementation with support for:
/// - Custom leading icons (back buttons, menu icons, etc.)
/// - Standard AppBar title and actions
/// - Responsive design with proper sizing
/// - Material Design compliance
/// 
/// @param height - Custom height for the app bar (optional)
/// @param leadingIcon - Path to the leading icon image (optional)
/// @param leadingWidth - Width for the leading widget area (optional)
/// @param title - Title widget to display in the center (optional)
/// @param centerTitle - Whether to center the title (optional)
/// @param actions - List of action widgets to display on the right (optional)
/// @param backgroundColor - Background color of the app bar (optional)
/// @param elevation - Elevation/shadow of the app bar (optional)
/// @param onLeadingPressed - Callback function when leading icon is pressed (optional)
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.height,
    this.leadingIcon,
    this.leadingWidth,
    this.title,
    this.centerTitle,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.onLeadingPressed,
  });

  /// Custom height for the app bar
  final double? height;

  /// Path to the leading icon image
  final String? leadingIcon;

  /// Width for the leading widget area
  final double? leadingWidth;

  /// Title widget to display in the center
  final Widget? title;

  /// Whether to center the title
  final bool? centerTitle;

  /// List of action widgets to display on the right
  final List<Widget>? actions;

  /// Background color of the app bar
  final Color? backgroundColor;

  /// Elevation/shadow of the app bar
  final double? elevation;

  /// Callback function when leading icon is pressed
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? appTheme.transparentCustom,
      automaticallyImplyLeading: false,
      leading: leadingIcon != null ? _buildLeadingIcon() : null,
      leadingWidth: leadingWidth ?? 65.h,
      title: title,
      centerTitle: centerTitle ?? false,
      actions: actions,
      titleSpacing: 0,
    );
  }

  /// Builds the leading icon widget
  Widget _buildLeadingIcon() {
    return GestureDetector(
      onTap: onLeadingPressed ?? () => Navigator.maybeOf(Get.context!)?.pop(),
      child: Container(
        margin: EdgeInsets.only(left: 33.h, top: 18.h, bottom: 18.h),
        child: CustomImageView(
          imagePath: leadingIcon ?? ImageConstant.imgGroup,
          height: 18.h,
          width: 20.h,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);
}
