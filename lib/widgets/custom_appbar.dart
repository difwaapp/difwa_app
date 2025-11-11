
import 'package:difwa_app/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppbar extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onNotificationPressed;
  final VoidCallback onMenuPressed;
  final bool hasNotifications;
  final int badgeCount; // Badge count for notifications
  final AppUser? usersData;

  const CustomAppbar({
    super.key,
    required this.onProfilePressed,
    required this.onNotificationPressed,
    required this.onMenuPressed,
    required this.hasNotifications,
    required this.badgeCount,
    this.usersData,
  });

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  bool get hasNotifications => widget.hasNotifications;
  int get badgeCount => widget.badgeCount;
  AppUser? get usersData => widget.usersData;

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + 8;
    final user = widget.usersData;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFf8f8f8), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 230, 230, 230),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Logo and App Name
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/dlogo.svg',
                height: 40,
              ),
              const SizedBox(width: 10),
            ],
          ),

          // Right side - Menu, Notifications, Profile
          Row(
            children: [
              // Menu Icon Button
              IconButton(
                icon: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF4A4A4A),
                  size: 28,
                ),
                onPressed: widget.onMenuPressed,
              ),

              // Notification Icon with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF4A4A4A),
                      size: 28,
                    ),
                    onPressed: widget.onNotificationPressed,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: widget.onProfilePressed,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade700,
                      backgroundImage: user != null &&
                              user.profileImage != null &&
                              user.profileImage!.isNotEmpty
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: (user == null ||
                              user.profileImage == null ||
                              user.profileImage!.isEmpty)
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              // Profile Avatar Icon
            ],
          ),
        ],
      ),
    );
  }
}
