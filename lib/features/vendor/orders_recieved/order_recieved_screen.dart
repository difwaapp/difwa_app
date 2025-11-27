import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderRecievedScreen extends StatefulWidget {
  const OrderRecievedScreen({super.key});

  @override
  State<OrderRecievedScreen> createState() => _OrderRecievedScreenState();
}

class _OrderRecievedScreenState extends State<OrderRecievedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseController _authController = Get.put(FirebaseController());
  final OrdersController _ordersController = Get.put(OrdersController());

  String merchantIdd = "";
  String uid = "";
  AppUser? usersData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ordersController.fetchOrdersWhereAllCompleted();

    print("hello");
    _authController.resolveMerchantId().then((merchantId) {
      print(merchantId);
      setState(() {
        merchantIdd = merchantId;
      });
      print("133");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 136.0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.deepPurple.shade700,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.blue.shade700,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.receipt_long,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        bottom: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage your vendor orders',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0.0),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.deepPurple.shade600,
                    unselectedLabelColor: Colors.grey.shade500,
                    indicatorColor: Colors.deepPurple.shade600,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            OrderListPage(status: 'pending', merchantId: merchantIdd),
            OrderListPage(status: 'Completed', merchantId: merchantIdd),
            OrderListPage(status: 'cancelled', merchantId: merchantIdd),
          ],
        ),
      ),
    );
  }

  Widget buildTab(String label, int count, IconData? icon) {
    return Tab(
      child: Row(
        children: [
          if (icon != null) const SizedBox(width: 4),
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(count.toString(), style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class OrderListPage extends StatefulWidget {
  final String status;
  final String merchantId;

  const OrderListPage({
    super.key,
    required this.status,
    required this.merchantId,
  });

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late AppUser userDetails;
  DateTime currentDate = DateTime.now();
  // DateTime currentDate = DateTime(2025, 4, 8);
  Map<String, AppUser> userCache = {}; // Cache for fetched user details
  final Set<String> _fetchingUids = {}; // Track pending fetches
  Map<String, Address> addressCache = {}; // Cache for fetched user addresses
  final FirebaseService _fs = Get.find();
  final AddressController _addressController = Get.put(AddressController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('merchantId', isEqualTo: widget.merchantId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching orders'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No ${widget.status} orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;

            // Filter selectedDates based on the current tab status
            final List<dynamic> allDates = order['selectedDates'] ?? [];
            final List<dynamic> filteredDates = allDates.where((dateData) {
              final status = dateData['status'] ?? 'pending';
              if (widget.status == 'Completed') {
                return status == 'delivered';
              } else if (widget.status == 'cancelled') {
                return status == 'cancelled';
              } else {
                // Pending tab shows active orders
                return [
                  'pending',
                  'confirmed',
                  'preparing',
                  'out_for_delivery',
                ].contains(status);
              }
            }).toList();

            // If no dates match the current tab's criteria, hide the card
            if (filteredDates.isEmpty) {
              return const SizedBox.shrink();
            }

            String uid = order['uid'];

            if (!userCache.containsKey(uid)) {
              fetchUserDetails(uid);
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (Order ID, Price, Date)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${orderId.substring(0, 8)}...", // Truncate ID for cleaner look
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy • hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  order['timestamp'].millisecondsSinceEpoch,
                                ).toLocal(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text(
                            '₹${order['totalPrice']}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Details Section
                        if (userCache.containsKey(uid)) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                userCache[uid]?.name ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                userCache[uid]?.number ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (addressCache.containsKey(uid))
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${addressCache[uid]!.locationType} ${addressCache[uid]!.floor}, ${addressCache[uid]!.street}, ${addressCache[uid]!.city}, ${addressCache[uid]!.zip}",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                        ],

                        // Items Section
                        const Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    color: Colors.blue.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${order['itemName'] ?? 'Water Can'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  "x${order['quantity'] ?? 1}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selected Dates Expansion
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.deepPurple.shade400,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        "Subscription Schedule",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        "${filteredDates.length} active dates",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      children:
                          filteredDates.map<Widget>((dateData) {
                            String dateStatus = dateData['status'] ?? 'pending';
                            
                            // Get timestamp for the current status
                            String timeString = '';
                            if (dateData['statusHistory'] != null &&
                                dateData['statusHistory'] is Map) {
                              Map history = dateData['statusHistory'];
                              Timestamp? ts;
                              if (dateStatus == 'delivered') {
                                ts = history['deliveredTime'];
                              } else if (dateStatus == 'cancelled') {
                                ts = history['cancelledTime'];
                              } else if (dateStatus == 'confirmed') {
                                ts = history['confirmedTime'];
                              }

                              if (ts != null) {
                                timeString =
                                    DateFormat('hh:mm a').format(ts.toDate());
                              }
                            }

                            Color statusColor;
                            Color statusBgColor;

                            switch (dateStatus) {
                              case 'delivered':
                                statusColor = Colors.green.shade700;
                                statusBgColor = Colors.green.shade50;
                                break;
                              case 'cancelled':
                                statusColor = Colors.red.shade700;
                                statusBgColor = Colors.red.shade50;
                                break;
                              case 'out_for_delivery':
                                statusColor = Colors.orange.shade800;
                                statusBgColor = Colors.orange.shade50;
                                break;
                              case 'preparing':
                                statusColor = Colors.blue.shade700;
                                statusBgColor = Colors.blue.shade50;
                                break;
                              default:
                                statusColor = Colors.grey.shade700;
                                statusBgColor = Colors.grey.shade100;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('MMM d, yyyy').format(
                                            DateTime.parse(dateData['date']),
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (timeString.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              timeString,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      dateStatus.replaceAll('_', ' ').capitalizeFirst!,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: Colors.grey.shade400,
                                      ),
                                      color: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) async {
                                        await changeDateStatus(
                                          context,
                                          orderId,
                                          dateData['date'],
                                          value,
                                          dateData['dailyOrderId'],
                                          userDetails,
                                          order,
                                        );
                                      },
                                      itemBuilder: (context) => [
                                        if (dateStatus != 'delivered' &&
                                            dateStatus != "cancelled")
                                          const PopupMenuItem<String>(
                                            value: 'preparing',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.soup_kitchen,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Preparing'),
                                              ],
                                            ),
                                          ),
                                        if (dateStatus == 'preparing' &&
                                            dateStatus != "cancelled")
                                          const PopupMenuItem<String>(
                                            value: 'out_for_delivery',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.local_shipping,
                                                  size: 18,
                                                  color: Colors.orange,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Out for Delivery'),
                                              ],
                                            ),
                                          ),
                                        if (dateStatus == 'out_for_delivery' &&
                                            dateStatus != "cancelled")
                                          const PopupMenuItem<String>(
                                            value: 'delivered',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Delivered'),
                                              ],
                                            ),
                                          ),
                                        if (dateStatus == 'pending' ||
                                            dateStatus == 'confirmed')
                                          const PopupMenuItem<String>(
                                            value: 'cancelled',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  size: 18,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Cancel'),
                                              ],
                                            ),
                                          ),
                                      ],
                                      enabled: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void fetchUserDetails(String uid) async {
    if (_fetchingUids.contains(uid)) return;
    _fetchingUids.add(uid);

    try {
      AppUser? userDetails = await _fs.fetchAppUser(uid);

      // Fetch address
      _addressController.getSelectedAddressByUid(uid).listen((address) {
        if (address != null && mounted) {
          setState(() {
            addressCache[uid] = address;
          });
        }
      });

      if (mounted && userDetails != null) {
        setState(() {
          this.userDetails = userDetails;
          userCache[uid] = userDetails; // Cache the user details
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    } finally {
      _fetchingUids.remove(uid);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible:
              false, // User must tap a button to close the dialog
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancels
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirms
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed without action
  }

  Future<void> changeOrderStatus(
    BuildContext context,
    String orderId,
    String newStatus,
  ) async {
    try {
      bool confirm = await _showConfirmationDialog(
        context,
        'Change Order Status',
        'Are you sure you want to change the order status to $newStatus?',
      );
      if (confirm) {
        DateTime currentTime = DateTime.now();
        await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
          'statusHistory': FieldValue.arrayUnion([
            {'status': newStatus, 'timestamp': currentTime},
          ]),
        });
        print('Order status updated successfully');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  bool _isOrderCompleted(List statusHistory) {
    // Check if all statuses in statusHistory are 'completed'
    return statusHistory.every((status) => status['status'] == 'completed');
  }

  Future<void> changeDateStatus(
    BuildContext context,
    String orderId,
    String date,
    String newStatus,
    String dailyOrderId,
    AppUser usersData,
    Map<String, dynamic> orderData, // Added orderData parameter
  ) async {
    try {
      if (newStatus == "delivered") {
        String enteredOtp = await _showPinDialog(context);
        String correctOtp = orderData['deliveryOtp'] ?? '';

        if (enteredOtp == correctOtp) {
          print("OTP Verified");
        } else {
          _showErrorDialog(
            context,
            "Incorrect OTP",
            "The entered OTP is incorrect. Please ask the customer for the correct OTP.",
          );
          return;
        }
      }

      bool confirm = await _showConfirmationDialog(
        context,
        'Change Date Status',
        'Are you sure you want to change the status of the date to $newStatus?',
      );
      if (confirm) {
        DateTime currentTime = DateTime.now();
        final orderDoc = FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId);

        // We already have orderData passed in, but to be safe and get fresh data for update logic:
        // (The passed orderData is good for OTP check, but for update we modify the list)
        // Actually, let's use the fresh fetch logic below or just use the passed one if we trust it.
        // For consistency with existing code, I'll keep the fetch logic but use the passed one for OTP.

        final orderSnapshot = await orderDoc.get();

        if (!orderSnapshot.exists) {
          print('Order not found');
          return;
        }

        final currentOrderData = orderSnapshot.data() as Map<String, dynamic>;

        if (currentOrderData['selectedDates'] == null ||
            currentOrderData['selectedDates'] is! List) {
          print('Selected dates not found or invalid');
          return;
        }

        final selectedDates = List<Map<String, dynamic>>.from(
          currentOrderData['selectedDates'],
        );

        // Find the index of the date in selectedDates list based on dailyOrderId
        final dateIndex = selectedDates.indexWhere(
          (item) => item['dailyOrderId'] == dailyOrderId,
        );

        print("DEBUG: changeDateStatus - dailyOrderId: $dailyOrderId");
        print("DEBUG: changeDateStatus - dateIndex: $dateIndex");

        // If the date is found, update the status and add to statusHistory
        if (dateIndex != -1) {
          selectedDates[dateIndex]['status'] = newStatus;
          // Update the status for the specific date

          // Ensure statusHistory is a Map
          Map<String, dynamic> history =
              (selectedDates[dateIndex]['statusHistory']
                  as Map<String, dynamic>?) ??
              {};
          history['status'] = newStatus;
          history['${newStatus}Time'] =
              currentTime; // e.g. deliveredTime, cancelledTime

          selectedDates[dateIndex]['statusHistory'] = history;

          await orderDoc.update({'selectedDates': selectedDates});

          print('Order date status updated successfully to $newStatus');
        } else {
          print(
            'Date with dailyOrderId $dailyOrderId not found in selectedDates',
          );
        }
      }
    } catch (e) {
      print('Error updating date status: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'status': 'cancelled',
          'statusHistory': FieldValue.arrayUnion([
            {'status': 'cancelled', 'timestamp': FieldValue.serverTimestamp()},
          ]),
        },
      );
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }

  Future<String> _showPinDialog(BuildContext context) async {
    TextEditingController pinController = TextEditingController();
    String enteredPin = '';

    // Show a dialog to enter pin
    await showDialog<String>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Delivery OTP'),
          content: TextField(
            controller: pinController,
            obscureText: false, // OTP is usually visible or number only
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter 4-digit OTP'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                enteredPin = pinController.text.trim();
                Navigator.of(context).pop(enteredPin); // Return the entered pin
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    return enteredPin;
  }

  Future<void> _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
