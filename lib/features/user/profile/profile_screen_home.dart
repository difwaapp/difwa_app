import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/vendor/stores_screens/store_onboarding_screen.dart';
import 'package:difwa_app/features/address/address_screen.dart';
import 'package:difwa_app/features/user/profile/controller/profile_controller.dart';
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

class _ProfileScreenState extends State<ProfileScreenHome> with WidgetsBindingObserver {
  AppUser? usersData;
  late final FirebaseService _fs;
  bool _isLoading = true;
  String? _errorMessage;
  bool _shouldRefreshOnResume = false;
  Worker? _profileUpdateWorker;

  @override
  void initState() {
    super.initState();
    
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

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
    
    // Listen for profile updates from ProfileController
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      _profileUpdateWorker = ever(profileCtrl.profileUpdated, (_) {
        print('[ProfileScreen] Profile update detected, refreshing...');
        _fetchUserData();
      });
    }
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes
    if (state == AppLifecycleState.resumed && _shouldRefreshOnResume) {
      _shouldRefreshOnResume = false;
      _fetchUserData();
    }
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
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern gradient app bar with profile
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                          Color(0xFF29B6F6), // Light blue
            Color(0xFF0288D1), // Darker blue
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Row(
                        children: [
                          _buildModernAvatar(),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usersData?.name ?? 'Guest',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  usersData?.email ?? 'guest@gmail.com',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (usersData?.role != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      usersData!.role,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Profile options
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernOption(
                      title: "Edit Profile",
                      subtitle: "Update your personal information",
                      icon: FontAwesomeIcons.userPen,
                      iconColor: Colors.blue,
                      onTap: () async {
                        // Set flag before navigating
                        _shouldRefreshOnResume = true;
                        // Navigate to edit screen and wait for result
                        final result = await Get.toNamed(AppRoutes.profileScreen);
                        // Immediately refresh data when coming back
                        if (result == true) {
                          await _fetchUserData();
                        }
                        // Reset flag
                        _shouldRefreshOnResume = false;
                      },
                    ),
                    _buildModernOption(
                      title: "Phone Number",
                      subtitle: usersData?.number ?? "Not available",
                      icon: FontAwesomeIcons.phone,
                      iconColor: Colors.green,
                      onTap: () {},
                    ),
                    _buildModernOption(
                      title: "Email Address",
                      subtitle: usersData?.email ?? "Not available",
                      icon: FontAwesomeIcons.envelope,
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernOption(
                      title: "Delivery Addresses",
                      subtitle: "Manage your delivery locations",
                      icon: FontAwesomeIcons.locationDot,
                      iconColor: Colors.red,
                      onTap: () => Get.to(() => const AddressScreen()),
                    ),
                    _buildModernOption(
                      title: "Become A Seller",
                      subtitle: "Start your business with us",
                      icon: FontAwesomeIcons.store,
                      iconColor: Colors.purple,
                      onTap: () => Get.to(() => const StoreOnboardingScreen()),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'More',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildModernOption(
                      title: "Logout",
                      subtitle: "Sign out of your account",
                      icon: FontAwesomeIcons.arrowRightFromBracket,
                      iconColor: Colors.red.shade700,
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAvatar() {
    final photo = usersData?.profileImage;
    final name = usersData?.name ?? '';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 42,
        backgroundColor: Colors.white,
        backgroundImage: (photo != null && photo.isNotEmpty)
            ? NetworkImage(photo) as ImageProvider
            : null,
        child: (photo == null || photo.isEmpty)
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'G',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildModernOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
