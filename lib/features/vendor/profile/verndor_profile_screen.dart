import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/vendor/profile/widget/custom_toggle_switch.dart';
import 'package:difwa_app/features/vendor/stores_screens/earnings.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class VerndorProfileScreen extends StatefulWidget {
  const VerndorProfileScreen({super.key});

  @override
  _VerndorProfileScreenState createState() => _VerndorProfileScreenState();
}

class _VerndorProfileScreenState extends State<VerndorProfileScreen> {
  final FirebaseService _fs = Get.find();
  final VendorsController vendorsController = Get.put(VendorsController());
  final OrdersController _ordersController = Get.put(OrdersController());
  AppUser? usersData;
  VendorModel? vendorData;
  bool notificationsEnabled = true;
  bool isLoading = true;
  bool isSwitched = false;

  int totalOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int preparingOrders = 0;
  int shippedOrders = 0;
  int overallTotalOrders = 0;
  int overallPendingOrders = 0;
  int overallCompletedOrders = 0;

  // Modern Flat Theme Colors
  static const Color primaryBackground = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color successColor = Color(0xFF00C853);
  static const Color warningColor = Color(0xFFFFAB00);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      setState(() => isLoading = true);
      print('Fetching user data...');

      AppUser? user = await _fs.fetchAppUser(
        FirebaseAuth.instance.currentUser!.uid,
      );

      print('Fetching vendor data...');
      vendorData = await vendorsController.fetchStoreData();
      print('Vendor data fetched: $vendorData');
      setState(() {
        if (vendorData?.isActive == true) {
          isSwitched = true;
        } else {
          isSwitched = false;
        }
      });

      print('Fetching orders data...');
      final ordersCounts = await _ordersController.fetchTotalTodayOrders();
      print('Orders data fetched: $ordersCounts');

      if (mounted) {
        setState(() {
          usersData = user;

          totalOrders = ordersCounts['totalOrders'] ?? 0;
          pendingOrders = ordersCounts['pendingOrders'] ?? 0;
          completedOrders = ordersCounts['completedOrders'] ?? 0;
          preparingOrders = ordersCounts['preparingOrders'] ?? 0;
          shippedOrders = ordersCounts['shippedOrders'] ?? 0;
          overallTotalOrders = ordersCounts['overallTotalOrders'] ?? 0;
          overallPendingOrders = ordersCounts['overallPendingOrders'] ?? 0;
          overallCompletedOrders = ordersCounts['overallCompletedOrders'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'Failed to load profile data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Business Information"),
                        const SizedBox(height: 16),
                        _buildBusinessInfoCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Account & Settings"),
                        const SizedBox(height: 16),
                        _buildSettingsList(),
                        const SizedBox(height: 40),
                        _buildLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _onLogout() async {
    if (Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      await authCtrl.logout();
      return;
    }

    // fallback direct firebase sign out
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.phoneLogin);
    } catch (e) {
      Get.snackbar(
        'Logout error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.3 < 250
          ? 250
          : MediaQuery.of(context).size.height * 0.3,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepPurple.shade800,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade900,
                Colors.deepPurple.shade600,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20.0,
              right: 20.0,
              bottom: 10.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (vendorData != null &&
                                  vendorData!.images.isNotEmpty &&
                                  vendorData!.images["aadharImg"] != null)
                              ? NetworkImage(vendorData!.images["aadharImg"]!)
                              : const AssetImage(
                                      'assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorData?.businessName ?? 'Business Name',
                              style: TextStyleHelper.instance.white14Regular
                                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "ID: ${vendorData?.merchantId ?? 'N/A'}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    vendorData?.businessAddress ?? 'Address',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Store Status",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSwitched ? "Online" : "Offline",
                              style: GoogleFonts.poppins(
                                color: isSwitched
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ModernToggleSwitch(
                              initialValue: isSwitched,
                              onToggle: (value) async {
                                await vendorsController.updateStoreDetails({
                                  "isActive": value,
                                });
                                setState(() {
                                  isSwitched = !isSwitched;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total Orders",
            totalOrders.toString(),
            Icons.shopping_bag_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Pending",
            pendingOrders.toString(),
            Icons.pending_actions_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Completed",
            completedOrders.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildBusinessInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.map_outlined, "Service Area",
              vendorData?.deliveryArea ?? "N/A"),
    Divider(height: 24, thickness: 1,color: appTheme.primaryColor.withOpacity(0.6),),
          _buildInfoRow(Icons.local_shipping_outlined, "Daily Capacity",
              vendorData?.dailySupply ?? "N/A"),
           Divider(height: 24, thickness: 1,color: appTheme.primaryColor.withOpacity(0.6),),
          _buildInfoRow(Icons.attach_money, "Pricing",
              vendorData?.capacityOptions ?? "N/A"),
             Divider(height: 24, thickness: 1,color: appTheme.primaryColor.withOpacity(0.6),),
          _buildInfoRow(Icons.access_time, "Operating Hours",
              vendorData?.deliveryTimings ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.account_balance_wallet_outlined,
          title: "Earnings Dashboard",
          subtitle: "View your financial performance",
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarningsDashboard(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.edit_outlined,
          title: "Edit Profile",
          subtitle: "Update your business details",
          color: Colors.blue,
          onTap: () => Get.toNamed(AppRoutes.vendor_edit_form),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return YesNoPopup(
                title: "Logout",
                description: "Are you sure you want to logout?",
                noButtonText: "Cancel",
                yesButtonText: "Logout",
                onNoButtonPressed: () => Navigator.pop(context),
                onYesButtonPressed: _onLogout,
              );
            },
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "Log Out",
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}