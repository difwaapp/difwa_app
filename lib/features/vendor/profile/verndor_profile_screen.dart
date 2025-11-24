import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/vendor/profile/widget/custom_toggle_switch.dart';
import 'package:difwa_app/features/vendor/stores_screens/earnings.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_button.dart';

class VerndorProfileScreen extends StatefulWidget {
  const VerndorProfileScreen({super.key});

  @override
  _VerndorProfileScreenState createState() => _VerndorProfileScreenState();
}

class _VerndorProfileScreenState extends State<VerndorProfileScreen> {
  final FirebaseService _fs = Get.find();
  final AuthController _userData = Get.put(AuthController());
  final VendorsController vendorsController = Get.put(VendorsController());
  final OrdersController _ordersController = Get.put(OrdersController());
  AppUser? usersData;
  VendorModal? vendorData;
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

     AppUser? user = await _fs.fetchAppUser(FirebaseAuth.instance.currentUser!.uid);

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
      backgroundColor: primaryBackground,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentColor))
          : CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium badge
                        _buildPremiumBadge(),
                        const SizedBox(height: 16),

                        // Performance Overview
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Performance Overview",
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                        fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "This Month",
                                    style: GoogleFonts.inter(
                                      color: accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  PerformanceMetric(
                                      label: "Deliveries",
                                      value: totalOrders.toString()),
                                  const PerformanceMetric(
                                      label: "Rating", value: "0.0"),
                                  const PerformanceMetric(
                                      label: "Response", value: "00%"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Business Details
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Business Details",
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                        fontSize: 16),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.vendor_edit_form);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit,
                                          color: accentColor, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              businessDetail("Service Area",
                                  vendorData?.deliveryArea ?? "N/A"),
                              businessDetail("Daily Capacity",
                                  vendorData?.dailySupply ?? "N/A"),
                              businessDetail("Pricing",
                                  vendorData?.capacityOptions ?? "N/A"),
                              businessDetail("Operating Hours",
                                  vendorData?.deliveryTimings ?? "N/A"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EarningsDashboard()),
                          ),
                          child: _buildCard(
                            padding: EdgeInsets.zero,
                            child: buildProfileOption(
                                'Earnings', 'View all financial data', Icons.attach_money),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: SizedBox(
                            child: CustomButton(
                              text: 'Logout',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return YesNoPopup(
                                      title: "Logout from app!",
                                      description:
                                          "Are you sure want to exit from application?",
                                      noButtonText: "No",
                                      yesButtonText: "Yes",
                                      onNoButtonPressed: () {
                                        Navigator.pop(context);
                                      },
                                      onYesButtonPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushReplacementNamed(
                                            context, '/login');
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 36,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.deepPurple.shade700,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade700, Colors.blue.shade700],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 32,
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
                              vendorData?.bussinessName ?? 'N/A',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vendorData?.merchantId ?? 'N/A',
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vendorData?.businessAddress ?? 'N/A',
                              style: GoogleFonts.inter(
                                  color: Colors.white60, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ModernToggleSwitch(
                        initialValue: isSwitched,
                        onToggle: (value) async {
                          print('Toggled: $value');
                          await vendorsController
                              .updateStoreDetails({"isActive": value});
                          setState(() {
                            isSwitched = !isSwitched;
                          });
                        },
                      )
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

  Widget _buildPremiumBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDAA520).withOpacity(0.3)),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDAA520).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Color(0xFFDAA520), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Service Provider",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDAA520),
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Upgrade to Premium for priority deliveries and exclusive benefits",
                  style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget businessDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;

  const PerformanceMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _VerndorProfileScreenState.accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: _VerndorProfileScreenState.textSecondary),
        )
      ],
    );
  }
}

Widget buildProfileOption(String title, String subtitle, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _VerndorProfileScreenState.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _VerndorProfileScreenState.accentColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.bold, color: _VerndorProfileScreenState.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(color: _VerndorProfileScreenState.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: _VerndorProfileScreenState.textSecondary),
      ],
    ),
  );
}
