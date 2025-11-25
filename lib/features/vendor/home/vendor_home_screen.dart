import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/features/vendor/home/widget/blinking_status_indicator.dart';
import 'package:difwa_app/features/vendor/store/store_widgets/order_tile.dart';
import 'package:difwa_app/features/vendor/stores_screens/payment_history_graph.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final FirebaseController _authController = Get.put(FirebaseController());
  final OrdersController _ordersController = Get.put(OrdersController());
  final VendorsController _vendorsController = Get.put(VendorsController());
  String? merchantIdd;
  bool vendorStatus = false;
  int todaytotalOrders = 0;
  int todaypendingOrders = 0;
  int todaycompletedOrders = 0;
  int todaypreparingOrders = 0;
  int todayshippedOrders = 0;
  int overallTotalOrders = 0;
  int overallPendingOrders = 0;
  int overallCompletedOrders = 0;
  double balance = 0;
  bool isLoading = true;
  String? errorMessage;

  // Modern Flat Theme Colors
  static const Color primaryBackground = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color accentColor = Color(0xFF6C63FF); // Modern Purple
  static const Color successColor = Color(0xFF00C853);
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color infoColor = Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch merchant ID
      final merchantId = await _vendorsController.fetchMerchantId();
      if (merchantId != null) {
        setState(() {
          merchantIdd = merchantId;
        });
        _vendorsController.fetchStoreDataRealTime(merchantId);
      } else {
        setState(() {
          errorMessage = 'Failed to fetch merchant ID';
          isLoading = false;
        });
        return;
      }

      // Fetch store data
      final vendor = await _vendorsController.fetchStoreData();
      setState(() {
        vendorStatus = vendor?.isActive ?? false;
        balance = vendor?.earnings ?? 0;
      });

      // Fetch order counts
      final ordersCounts = await _ordersController.fetchTotalTodayOrders();
      setState(() {
        todaytotalOrders = ordersCounts['totalOrders'] ?? 0;
        todaypendingOrders = ordersCounts['pendingOrders'] ?? 0;
        todaycompletedOrders = ordersCounts['completedOrders'] ?? 0;
        todaypreparingOrders = ordersCounts['preparingOrders'] ?? 0;
        todayshippedOrders = ordersCounts['shippedOrders'] ?? 0;
        overallTotalOrders = ordersCounts['overallTotalOrders'] ?? 0;
        overallPendingOrders = ordersCounts['overallPendingOrders'] ?? 0;
        overallCompletedOrders = ordersCounts['overallCompletedOrders'] ?? 0;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      );
    }

    if (errorMessage != null || merchantIdd == null || merchantIdd!.isEmpty) {
      return Scaffold(
        backgroundColor: primaryBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Merchant ID not found',
                style: GoogleFonts.inter(fontSize: 16, color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryBackground,
      body: CustomScrollView(
        slivers: [
          // Modern Header
          _buildHeader(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section
                  _buildSectionTitle("Overview"),
                  const SizedBox(height: 20),
                  // Enhanced Stats Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Orders',
                          value: overallTotalOrders.toString(),
                          icon: Icons.shopping_bag_outlined,
                          iconColor: infoColor,
                          bgColor: infoColor.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Revenue',
                          value: '₹${balance.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: successColor,
                          bgColor: successColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Today Status Section
                  _buildSectionTitle("Today's Status"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Pending',
                          value: todaypendingOrders.toString(),
                          icon: Icons.pending_outlined,
                          color: warningColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Shipped',
                          value: todayshippedOrders.toString(),
                          icon: Icons.local_shipping_outlined,
                          color: infoColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Completed',
                          value: todaycompletedOrders.toString(),
                          icon: Icons.check_circle_outline,
                          color: successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Revenue Trend Chart
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Revenue Trend",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "This Week",
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 200, child: LineChartWidget()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Recent Orders Section
                  _buildSectionTitle("Recent Orders"),
                  const SizedBox(height: 16),
                  _buildCardContainer(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      height: 600,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('orders')
                            .where('merchantId', isEqualTo: merchantIdd)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Error loading orders',
                                    style: GoogleFonts.inter(
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final orders = snapshot.data?.docs ?? [];
                          if (orders.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 64,
                                    color: Colors.black12,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No orders available.',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order =
                                  orders[index].data() as Map<String, dynamic>;
                              final orderId = orders[index].id;
                              final orderStatus = order['status'] ?? 'pending';
                              final totalPrice =
                                  order['totalPrice']?.toString() ?? '0';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: OrderTile(
                                  orderId: orderId,
                                  details: '₹$totalPrice',
                                  status: orderStatus,
                                  color: Colors.blue,
                                ),
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

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 96.0,
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
                Obx(() {
                  final isActive = _vendorsController.vendorStatus.value;
                  final vendorName = _vendorsController.vendorName.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back! 👋',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendorName.isEmpty ? 'Vendor' : vendorName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlinkingStatusIndicator(isActive: isActive),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
