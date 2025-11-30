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
      if (!mounted) return;

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
      if (!mounted) return;
      
      setState(() {
        vendorStatus = vendor?.isActive ?? false;
        balance = vendor?.earnings ?? 0;
      });

      // Fetch order counts
      final ordersCounts = await _ordersController.fetchTotalTodayOrders();
      if (!mounted) return;

      setState(() {
        todaytotalOrders = ordersCounts['totalOrders'] ?? 0;
        todaypendingOrders = ordersCounts['pendingOrders'] ?? 0;
        todaycompletedOrders = ordersCounts['completedOrders'] ?? 0;
        todaypreparingOrders = ordersCounts['preparingOrders'] ?? 0;
        todayshippedOrders = ordersCounts['shippedOrders'] ?? 0;
        overallTotalOrders = ordersCounts['overallTotalOrders'] ?? 0;
        overallPendingOrders = ordersCounts['overallPendingOrders'] ?? 0;
        overallCompletedOrders = ordersCounts['overallCompletedOrders'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
                style: GoogleFonts.poppins(fontSize: 16, color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
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
                  _buildSectionTitle("Overview"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Orders',
                          value: overallTotalOrders.toString(),
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Revenue',
                          value: '₹${balance.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Today's Status"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Pending',
                          value: todaypendingOrders.toString(),
                          icon: Icons.pending_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Shipped',
                          value: todayshippedOrders.toString(),
                          icon: Icons.local_shipping_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          label: 'Completed',
                          value: todaycompletedOrders.toString(),
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Revenue Trend",
                              style: GoogleFonts.poppins(
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
                                style: GoogleFonts.poppins(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 200, child: PaymentHistoryGraph()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Recent Orders"),
                      TextButton(
                        onPressed: () {
                          // Navigate to Orders tab logic if needed
                          // For now, it's just visual or could switch tab
                        },
                        child: Text(
                          "View All",
                          style: GoogleFonts.poppins(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecentOrdersList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    final isActive = _vendorsController.vendorStatus.value;
                    final vendorName = _vendorsController.vendorName.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome Back! 👋',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendorName.isEmpty ? 'Vendor' : vendorName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        BlinkingStatusIndicator(isActive: isActive),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: textPrimary,
      ),
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
    required Color color,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textSecondary,
              fontSize: 12,
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
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

  Widget _buildRecentOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('merchantId', isEqualTo: merchantIdd)
          .orderBy('timestamp', descending: true)
          .limit(5) // Limit to recent 5
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading orders',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final orders = snapshot.data?.docs ?? [];
        if (orders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No recent orders',
                  style: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            final orderStatus = order['status'] ?? 'pending';
            final totalPrice = order['totalPrice']?.toString() ?? '0';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: OrderTile(
                orderId: orderId,
                details: '₹$totalPrice',
                status: orderStatus,
                color: _getStatusColor(orderStatus),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'out_for_delivery':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
