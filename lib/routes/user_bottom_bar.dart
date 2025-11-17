import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/screens/book_now_screen.dart';
import 'package:difwa_app/screens/ordershistory_screen.dart';
import 'package:difwa_app/screens/profile_screen_home.dart';
import 'package:difwa_app/screens/user_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BottomUserHomePage extends StatefulWidget {
  const BottomUserHomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

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
      ProfileScreenHome(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on Home, go to Home
      _onItemTapped(0);
      return false;
    }

    // Handle double back press to exit
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: appTheme.primaryColor,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.only(top: 5.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: appTheme.blackColor,
                blurRadius: 3.0,
                spreadRadius: 0.5,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0),
              bottom: Radius.circular(8),
            ),
          ),
          child: BottomNavigationBar(
            selectedLabelStyle: TextStyleHelper.instance.body14BoldPoppins,
            unselectedItemColor: appTheme.primaryColor,
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildSvgIcon(
                  'assets/icons/home.svg',
                  'assets/icons/home_filled.svg',
                  0,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildSvgIcon(
                  'assets/icons/order.svg',
                  'assets/icons/order_filled.svg',
                  1,
                ),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: _buildSvgIcon(
                  'assets/icons/wallet.svg',
                  'assets/icons/wallet_filled.svg',
                  2,
                ),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: _buildSvgIcon(
                  'assets/icons/profile.svg',
                  'assets/icons/profile_filled.svg',
                  3,
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: appTheme.blackColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String unselectedPath, String selectedPath, int index) {
    bool isSelected = _selectedIndex == index;
    return SvgPicture.asset(
      isSelected ? selectedPath : unselectedPath,
      width: isSelected ? 30 : 24,
      height: isSelected ? 30 : 24,
      colorFilter: ColorFilter.mode(
        isSelected ? appTheme.primaryColor : appTheme.blackColor,
        BlendMode.srcIn,
      ),
    );
  }
}
