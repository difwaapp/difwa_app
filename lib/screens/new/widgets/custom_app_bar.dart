import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'custom_image_view.dart';
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
