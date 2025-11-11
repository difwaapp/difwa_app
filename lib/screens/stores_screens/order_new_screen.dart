import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/order_controller.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
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
    _authController.fetchMerchantId("").then((merchantId) {
      print(merchantId);
      setState(() {
        merchantIdd = merchantId!;
      });
      print("133");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:appTheme.whiteColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            buildTab("Pending", 0, Icons.access_time),
            buildTab("Completed", 0, Icons.check),
            buildTab("Cancelled", 0, Icons.close),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrderListPage(
            status: 'pending',
            merchantId: merchantIdd,
          ),
          OrderListPage(
            status: 'Completed',
            merchantId: merchantIdd,
            // Provide a default value or handle null
          ),
          OrderListPage(
            status: 'cancelled',
            merchantId: merchantIdd,
          )
        ],
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
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          )
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
  Map<String, AppUser> userCache =
      {}; // Cache for fetched user details

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

            String uid = order['uid'];

            if (!userCache.containsKey(uid)) {
              fetchUserDetails(uid);
            }

            return Card(
              color: appTheme.whiteColor,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                // title: Text('Order ID: $orderId'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order : #$orderId",
                          style: TextStyleHelper.instance.black14Bold,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E9FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹ ${order['totalPrice'].toString()}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Adjust alignment as needed
                      children: [
                        Text(
                          style: TextStyleHelper.instance.black14Bold.copyWith(
                              color: appTheme.gray100),
                          '${DateFormat('MMMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(order['timestamp'].millisecondsSinceEpoch).toLocal())} ',
                        ),
                        Text(
                          style: TextStyleHelper.instance.black14Bold.copyWith(
                              color: appTheme.gray100),
                          DateFormat('HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                      order['timestamp'].millisecondsSinceEpoch)
                                  .toLocal()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tilePadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person),
                      title: const Text("Selected Dates"),
                      children: order['selectedDates']
                          .where((dateData) => widget.status == 'Completed'
                              ? dateData['status'] == 'Completed'
                              : true)
                          .map<Widget>((dateData) {
                        // DateTime date = DateTime.parse(dateData['date']);
                        // DateTime date = DateTime(2025, 4, 8);
                        String dateStatus = dateData['status'] ?? 'pending';
                        bool isCurrentDate = _isSameDay(
                            DateTime.parse(dateData['date']), currentDate);

                        // print("Current date")
                        // print("pritam");
                        // print(dateData['status']);

                        // print(dateData['date']);
                        return ListTile(
                          // textColor: Colors.red,
                          title: Text(
                            '${DateFormat('MMMM d, yyyy').format(DateTime.parse(dateData['date']))} ',
                            // '${DateFormat('HH:mm').format(DateTime.parse(dateData['date']))}',

                            style: TextStyle(
                                color: _isSameDay(
                                        DateTime.parse(dateData['date']),
                                        currentDate)
                                    ? Colors.green
                                    : Colors.grey),
                          ),
                          subtitle: Text('Status: $dateStatus'),

                          trailing: PopupMenuButton<String>(
                            color: Colors.white,
                            onSelected: isCurrentDate
                                ? (value) async {
                                    print("daily order id");
                                    print(dateData['dailyOrderId']);
                                    await changeDateStatus(
                                        context, // Pass context here
                                        orderId,
                                        dateData['date'],
                                        value,
                                        dateData['dailyOrderId'],
                                        userDetails);
                                  }
                                : null,
                            itemBuilder: (context) => [
                              if (isCurrentDate)
                                if (dateStatus == 'pending' &&
                                    dateStatus != "Cancel")
                                  const PopupMenuItem<String>(
                                    value: 'Preparing',
                                    child: Text('Preparing'),
                                  ),
                              if (isCurrentDate)
                                if (dateStatus == 'Preparing' &&
                                    dateStatus != "Cancel")
                                  const PopupMenuItem<String>(
                                    value: 'Shipped',
                                    child: Text('Shipped'),
                                  ),
                              if (isCurrentDate)
                                if (dateStatus == 'Shipped' &&
                                    dateStatus != "Cancel")
                                  const PopupMenuItem<String>(
                                    value: 'Completed',
                                    child: Text('Completed'),
                                  ),
                              if (isCurrentDate)
                                if (dateStatus == 'pending')
                                  const PopupMenuItem<String>(
                                    value: 'Cancel',
                                    child: Text('Cancel'),
                                  ),
                            ],
                          ),
                          enabled:
                              isCurrentDate, // Disable if it's not the current date
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void fetchUserDetails(String uid) async {
    AuthController authController = Get.put(AuthController());
    AppUser userDetails =
        await authController.fetchUserDatabypassUserId(uid);
    print("User data for pin:");
    print(userDetails.orderpin);

    setState(() {
      this.userDetails = userDetails;
      userCache[uid] = userDetails; // Cache the user details
    });

    if (userCache.containsKey(uid)) {
      setState(() {
        userDetails = userCache[uid]!;
      });
      return;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String message) async {
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
      BuildContext context, String orderId, String newStatus) async {
    try {
      bool confirm = await _showConfirmationDialog(
          context,
          'Change Order Status',
          'Are you sure you want to change the order status to $newStatus?');
      if (confirm) {
        DateTime currentTime = DateTime.now();
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .set({
          'statusHistory': FieldValue.arrayUnion([
            {
              'status': newStatus,
              'timestamp': currentTime,
            }
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
      AppUser usersData) async {
    try {
      String pin;
      if (newStatus == "Completed") {
        print("PRI :: $newStatus");
        print("PIN :: ${usersData.orderpin}");
        pin = await _showPinDialog(context);
        if (usersData.orderpin == pin) {
          print("PRI3 :: $pin");
        } else {
          _showErrorDialog(context, "Entered pipn is wrong ",
              "Please insure your pin is correct");
          return;
        }
      } else {
        print("PRI1 :: $newStatus");
      }

      bool confirm = await _showConfirmationDialog(
          context,
          'Change Date Status',
          'Are you sure you want to change the status of the date to $newStatus?');
      if (confirm) {
        DateTime currentTime = DateTime.now();
        final orderDoc =
            FirebaseFirestore.instance.collection('orders').doc(orderId);
        final orderSnapshot = await orderDoc.get();

        if (!orderSnapshot.exists) {
          print('Order not found');
          return;
        }

        final orderData = orderSnapshot.data() as Map<String, dynamic>;

        if (orderData['selectedDates'] == null ||
            orderData['selectedDates'] is! List) {
          print('Selected dates not found or invalid');
          return;
        }

        final selectedDates =
            List<Map<String, dynamic>>.from(orderData['selectedDates']);

        // Find the index of the date in selectedDates list based on dailyOrderId
        final dateIndex = selectedDates
            .indexWhere((item) => item['dailyOrderId'] == dailyOrderId);

        // If the date is found, update the status and add to statusHistory
        if (dateIndex != -1) {
          selectedDates[dateIndex]['status'] = newStatus;
          // Update the status for the specific date
          selectedDates[dateIndex]['statusHistory']['status'] = newStatus;

          if (selectedDates[dateIndex]['statusHistory'] == null) {
            selectedDates[dateIndex]['statusHistory'] = {};
          }

          selectedDates[dateIndex]['statusHistory']['${newStatus}Time'] =
              currentTime;

          await orderDoc.update({
            'selectedDates': selectedDates,
          });

          print('Order date status updated successfully');
        } else {
          print(
              'Date with dailyOrderId $dailyOrderId not found in selectedDates');
        }
      }
    } catch (e) {
      print('Error updating date status: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'cancelled',
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
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
          title: const Text('Enter Pin to Complete Order'),
          content: TextField(
            controller: pinController,
            obscureText: true, // Obscure the input for pin security
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter your pin'),
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
      BuildContext context, String title, String message) async {
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
