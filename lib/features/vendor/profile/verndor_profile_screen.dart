import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/vendor/store/store_widgets/custom_toggle_switch.dart';
import 'package:difwa_app/features/vendor/stores_screens/earnings.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      setState(() => isLoading = true); // Ensure loading starts
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
      backgroundColor: const Color(0xFFF8F9FB),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)))
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(
                      top: 40, bottom: 20, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: isSwitched
                        ? Color.fromARGB(255, 0, 197, 105)
                        : Color(0xFF2196F3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            backgroundImage: (vendorData != null &&
                                    vendorData!.images.isNotEmpty &&
                                    vendorData!.images["aadharImg"] != null)
                                ? NetworkImage(vendorData!.images["aadharImg"]!)
                                : const AssetImage(
                                        'assets/images/default_avatar.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendorData?.bussinessName ?? 'N/A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  vendorData?.merchantId ?? 'N/A',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  vendorData?.businessAddress ?? 'N/A',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
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
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Premium Service Provider",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium badge
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Premium Service Provider",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Upgrade to Premium for priority deliveries and exclusive benefits",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Performance Overview
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "Performance Overview",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    "This Month",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Business Details",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.vendor_edit_form);
                                    },
                                    child: const Icon(Icons.edit,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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

                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EarningsDashboard()),
                          ),
                          child: buildProfileOption(
                              'Earnings', 'all data', Icons.attach_money),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            child: CustomButton(
                              baseTextColor: appTheme.gray100,
                              backgroundColor: appTheme.primaryColor,
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              height: 50,
                              width: double.infinity,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget businessDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        )
      ],
    );
  }
}

Widget buildProfileOption(String title, String subtitle, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, color:appTheme.primaryColor,),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}
