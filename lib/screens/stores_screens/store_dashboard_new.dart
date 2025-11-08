import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/screens/store_widgets/blinking_status_indicator.dart';
import 'package:difwa_app/screens/store_widgets/order_tile.dart';
import 'package:difwa_app/screens/store_widgets/state_card.dart';
import 'package:difwa_app/screens/store_widgets/status_card.dart';
import 'package:difwa_app/screens/stores_screens/payment_history_graph.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseController _authController = Get.put(FirebaseController());
  final OrdersController _ordersController = Get.put(OrdersController());
  final VendorsController _vendorsController = Get.put(VendorsController());
  String? merchantIdd;
  bool storeStatus = false;

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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch merchant ID

      final merchantId = await _vendorsController.fetchMerchantId();
      print('Merchant ID: $merchantId');
      if (merchantId != null) {
        print('Merchant ID: $merchantId');

        setState(() {
          merchantIdd = merchantId;
        });
        _vendorsController.fetchStoreDataRealTime(merchantId);
      } else {
        setState(() {
          errorMessage = 'Faiasdasdled to fetch merchant ID';
          isLoading = false;
        });
        return;
      }

      // Fetch store data
      final vendor = await _vendorsController.fetchStoreData();
      setState(() {
        storeStatus = vendor?.isActive ?? false;
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
      print("hello data ");

      // Fetch merchant ID from auth controller (if needed)
      // final authMerchantId = await _authController.fetchMerchantId("");
      setState(() {
        // merchantIdd = authMerchantId ?? merchantIdd;
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || merchantIdd == null || merchantIdd!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage ?? 'Merchant ID not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Static Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final isActive = _vendorsController.storeStatus.value;
                    final vendorName = _vendorsController.vendorName.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome, ${vendorName.isEmpty ? 'Vendor' : vendorName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            BlinkingStatusIndicator(isActive: isActive),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Overview",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(
                          title: 'All Total Orders',
                          value: overallTotalOrders.toString(),
                          color: Colors.green,
                        ),
                        StatCard(
                          title: 'Revenue',
                          value: '₹${balance.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Today Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Today Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusCard(
                          label: 'Pending Orders',
                          value: todaypendingOrders.toString(),
                          color: Colors.orange,
                        ),
                        StatusCard(
                          label: 'Shipped Orders',
                          value: todayshippedOrders.toString(),
                          color: Colors.blue,
                        ),
                        StatusCard(
                          label: 'Completed Orders',
                          value: todaycompletedOrders.toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Revenue Trend",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "This Week",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                          SizedBox(height: 200, child: LineChartWidget()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Recent Orders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Recent Orders",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 600,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('difwa-orders')
                            .where('merchantId', isEqualTo: merchantIdd)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading orders'),
                            );
                          }

                          final orders = snapshot.data?.docs ?? [];
                          if (orders.isEmpty) {
                            return const Center(
                              child: Text('No orders available.'),
                            );
                          }

                          return ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order =
                                  orders[index].data() as Map<String, dynamic>;
                              final orderId = orders[index].id;
                              final orderStatus = order['status'] ?? 'pending';
                              final totalPrice =
                                  order['totalPrice']?.toString() ?? '0';

                              return OrderTile(
                                orderId: orderId,
                                details: '₹$totalPrice',
                                status: orderStatus,
                                color: Colors.blue,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
