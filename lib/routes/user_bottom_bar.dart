import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/screens/book_now_screen.dart';
import 'package:difwa_app/screens/ordershistory_screen.dart';
import 'package:difwa_app/screens/profile_screen_home.dart';
import 'package:difwa_app/screens/user_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BottomUserHomePage extends StatefulWidget {
  const BottomUserHomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// Flipkart-like modern bottom navigation with centered FAB and safe animations.
class _HomeScreenState extends State<BottomUserHomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();

    _screens = [
      BookNowScreen(
        onProfilePressed: () => _onItemTapped(3),
        onMenuPressed: () => _onItemTapped(2),
      ),
      HistoryScreen(),
      WalletScreen(
        onProfilePressed: () => _onItemTapped(3),
        onMenuPressed: () => _onItemTapped(2),
      ),
      const ProfileScreenHome(),
    ];
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      _onItemTapped(0);
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      Fluttertoast.showToast(
        msg: 'Press back again to exit',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
    return true;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _navIcon(String assetPath, bool active, {double size = 24}) {
    // Use `color` instead of ColorFilter to avoid painting issues
    final Color iconColor = active ? appTheme.primaryColor : Colors.black54;
    return AnimatedScale(
      scale: active ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        color: iconColor,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = appTheme.whiteColor;
    final primary = appTheme.primaryColor;
    final shadowColor = Colors.black.withOpacity(0.08);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: appTheme.gray100,
        // keep pages alive
        body: SafeArea(
          top: false,
          child: IndexedStack(index: _selectedIndex, children: _screens),
        ),

        // Floating action button in center (Flipkart-style)
        floatingActionButton: SizedBox(
          height: 64, // bigger
          width: 64, // bigger
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40), // full round
            ),
            onPressed: () {
              _onItemTapped(0);
            },
            elevation: 8,
            backgroundColor: primary,
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 30, // bigger icon
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: PhysicalShape(
            elevation: 8,
            color: bg,
            shadowColor: shadowColor,
            clipper: _NavBarClipper(), // rounded notch
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Left two items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildItem(0, 'assets/icons/home.svg', 'Home'),
                        _buildItem(1, 'assets/icons/order.svg', 'Orders'),
                      ],
                    ),
                  ),

                  // Spacer for center FAB notch
                  const SizedBox(width: 10),

                  // Right two items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildItem(2, 'assets/icons/wallet.svg', 'Wallet'),
                        _buildItem(3, 'assets/icons/profile.svg', 'Profile'),
                      ],
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

  Widget _buildItem(int index, String assetPath, String label) {
    final bool active = _selectedIndex == index;
    final Color primaryColor = appTheme.primaryColor;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navIcon(assetPath, active),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyleHelper.instance.customText(
                fontSize: active ? 12 : 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? primaryColor : Colors.black54,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clipper that leaves a centered notch for the FAB and rounds the bar.
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path p = Path();
    final double width = size.width;
    final double height = size.height;
    const double notchRadius = 36;
    const double notchWidth = notchRadius * 2 + 10;
    final double notchCenter = width / 2;

    // Start at left
    p.moveTo(0, 16);
    // left corner curve
    p.quadraticBezierTo(0, 0, 16, 0);
    // top line to before notch
    p.lineTo(notchCenter - notchWidth / 2 - 12, 0);
    // begin notch curve
    p.quadraticBezierTo(
      notchCenter - notchWidth / 2,
      0,
      notchCenter - notchWidth / 2 + 6,
      12,
    );
    p.arcToPoint(
      Offset(notchCenter + notchWidth / 2 - 6, 12),
      radius: Radius.circular(notchRadius + 6),
      clockwise: false,
    );
    p.quadraticBezierTo(
      notchCenter + notchWidth / 2,
      0,
      notchCenter + notchWidth / 2 + 12,
      0,
    );
    // continue top line to right corner
    p.lineTo(width - 16, 0);
    p.quadraticBezierTo(width, 0, width, 16);
    // right edge down
    p.lineTo(width, height - 16);
    p.quadraticBezierTo(width, height, width - 16, height);
    // bottom line
    p.lineTo(16, height);
    p.quadraticBezierTo(0, height, 0, height - 16);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
