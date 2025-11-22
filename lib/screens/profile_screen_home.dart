import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/screens/stores_screens/store_onboarding_screen.dart';
import 'package:difwa_app/screens/address/address_screen.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:difwa_app/widgets/simmers/ProfileShimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreenHome extends StatefulWidget {
  const ProfileScreenHome({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenHome> {
  AppUser? usersData;
  late final FirebaseService _fs;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Defensive: ensure FirebaseService is registered
    if (!Get.isRegistered<FirebaseService>()) {
      // avoid throwing — show friendly error and stop loading
      _isLoading = false;
      _errorMessage = 'Service unavailable. Please restart the app.';
      // Print for debug
      print('[ProfileScreen] FirebaseService not registered');
      return;
    }

    _fs = Get.find<FirebaseService>();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No authenticated user.';
        });
        return;
      }

      final AppUser? user = await _fs.fetchAppUser(uid);

      if (!mounted) return;
      setState(() {
        usersData = user;
        _isLoading = false;
      });
    } catch (e, st) {
      print('[ProfileScreen] fetch error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile. Pull to retry.';
      });
      Get.snackbar(
        'Error',
        'Unable to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onLogout() async {
    // Prefer AuthController if available (keeps central logic)
    if (Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      await authCtrl.logout();
      return;
    }

    // fallback direct firebase sign out
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Logout error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ProfileShimmer();
    }

    // Error UI
    if (_errorMessage != null && usersData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  style: TextStyleHelper.instance.body14RegularPoppins,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchUserData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('My Profile'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 14),
                    _buildNameEmailColumn(),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    buildProfileOption(
                      title: "Profile",
                      subtitle: "Edit profile details",
                      icon: FontAwesomeIcons.user,
                      onTap: () => Get.toNamed(AppRoutes.profileScreen),
                    ),
                    buildProfileOption(
                      title: "Phone Number",
                      subtitle: usersData?.number ?? "Not available",
                      icon: FontAwesomeIcons.phone,
                      onTap: () {}, // optionally open phone edit
                    ),
                    buildProfileOption(
                      title: "Email Address",
                      subtitle: usersData?.email ?? "Not available",
                      icon: FontAwesomeIcons.envelope,
                      onTap: () {}, // optionally open email edit
                    ),
                    buildProfileOption(
                      title: "Delivery Address",
                      subtitle: "Manage multiple addresses",
                      icon: FontAwesomeIcons.locationDot,
                      onTap: () => Get.to(() => const AddressScreen()),
                    ),
                    buildProfileOption(
                      title: "Become A Seller",
                      subtitle: "Start selling your products today!",
                      icon: FontAwesomeIcons.store,
                      onTap: () => Get.to(() => const StoreOnboardingScreen()),
                    ),
                    buildProfileOption(
                      title: "Logout",
                      subtitle: "Sign out of your account",
                      icon: FontAwesomeIcons.arrowRightFromBracket,
                      onTap: () {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) {
                            return YesNoPopup(
                              title: "Logout from app!",
                              description:
                                  "Are you sure you want to exit from the application?",
                              noButtonText: "No",
                              yesButtonText: "Yes",
                              onNoButtonPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              onYesButtonPressed: () async {
                                Navigator.pop(dialogContext);
                                await _onLogout();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final photo = usersData?.profileImage;
    final name = usersData?.name ?? '';
    return CircleAvatar(
      radius: 38,
      backgroundColor: Colors.blue.shade700,
      backgroundImage: (photo != null && photo.isNotEmpty)
          ? NetworkImage(photo) as ImageProvider
          : null,
      child: (photo == null || photo.isEmpty)
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'G',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildNameEmailColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          usersData?.name ?? 'Guest',
          style: TextStyleHelper.instance.black14Bold,
        ),
        const SizedBox(height: 6),
        Text(
          usersData?.email ?? 'guest@gmail.com',
          style: TextStyleHelper.instance.body12RegularPoppins,
        ),
        const SizedBox(height: 4),
        if (usersData?.role != null)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              usersData!.role,
              style: TextStyleHelper.instance.caption12,
            ),
          ),
      ],
    );
  }

  Widget buildProfileOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
