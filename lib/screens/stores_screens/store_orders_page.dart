// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:difwa/controller/admin_controller/add_items_controller.dart';
// import 'package:difwa/controller/auth_controller.dart';
// import 'package:difwa/models/user_models/user_details_model.dart';
// import 'package:difwa/utils/theme_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AdminPanelScreen extends StatefulWidget {
//   const AdminPanelScreen({super.key});

//   @override
//   State<AdminPanelScreen> createState() => _AdminPanelScreenState();
// }

// class _AdminPanelScreenState extends State<AdminPanelScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final FirebaseController _authController = Get.put(FirebaseController());
//   String merchantIdd = "";
//   String userId = "";
//   UserDetailsModel? usersData;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     print("hello");
//     _authController.fetchMerchantId("").then((merchantId) {
//       print(merchantId);
//       setState(() {
//         merchantIdd = merchantId!;
//       });
//       print("133");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeConstants.whiteColor,
//       appBar: AppBar(
//         toolbarHeight: 0,
//         backgroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.blue,
//           labelColor: Colors.blue,
//           unselectedLabelColor: Colors.grey,
//           tabs: const [
//             Tab(icon: Icon(Icons.pending), text: 'Pending'),
//             Tab(icon: Icon(Icons.check_box), text: 'Completed'),
//             Tab(icon: Icon(Icons.cancel), text: 'Cancelled'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           OrderListPage(
//             status: 'pending',
//             merchantId: merchantIdd,
//           ),
//           OrderListPage(
//             status: 'completed',
//             merchantId: merchantIdd,
//             // Provide a default value or handle null
//           ),
//           OrderListPage(
//             status: 'cancelled',
//             merchantId: merchantIdd,
//           )
//         ],
//       ),
//     );
//   }
// }

// class OrderListPage extends StatefulWidget {
//   final String status;
//   final String merchantId;

//   const OrderListPage({
//     super.key,
//     required this.status,
//     required this.merchantId,
//   });

//   @override
//   _OrderListPageState createState() => _OrderListPageState();
// }

// class _OrderListPageState extends State<OrderListPage> {
//   late UserDetailsModel userDetails;
//   DateTime currentDate = DateTime.now();
//   Map<String, UserDetailsModel> userCache =
//       {}; // Cache for fetched user details

//   @override
//   Widget build(BuildContext context) {
//     DateTime currentDate = DateTime.now();
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('difwa-orders')
//           .where('merchantId', isEqualTo: widget.merchantId)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return const Center(child: Text('Error fetching orders'));
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               'No ${widget.status} orders found.',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           );
//         }
//         final orders = snapshot.data!.docs;

//         return ListView.builder(
//           padding: const EdgeInsets.all(8.0),
//           itemCount: orders.length,
//           itemBuilder: (context, index) {
//             final order = orders[index].data() as Map<String, dynamic>;
//             final orderId = orders[index].id;

//             String userId = order['userId'];

//             // Only fetch user details if not already in cache
//             if (!userCache.containsKey(userId)) {
//               fetchUserDetails(userId);
//             }

//             return Card(
//               color: ThemeConstants.whiteColor,
//               margin: const EdgeInsets.symmetric(vertical: 8.0),
//               child: ListTile(
//                 title: Text('Order ID: $orderId'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Total Price: ₹ ${order['totalPrice']}'),
//                     Text(
//                       'Order Date: ${DateTime.fromMillisecondsSinceEpoch(order['timestamp'].millisecondsSinceEpoch)}',
//                     ),
//                     const SizedBox(height: 8),
//                     ExpansionTile(
//                       title: const Text("Selected Dates"),
//                       children: order['selectedDates']
//                           .where((dateData) => widget.status == 'Completed'
//                               ? dateData['status'] == 'Completed'
//                               : true)
//                           .map<Widget>((dateData) {
//                         DateTime date = DateTime.parse(dateData['date']);
//                         String dateStatus = dateData['status'] ?? 'pending';
//                         bool isCurrentDate = _isSameDay(date, currentDate);
//                         return ListTile(
//                           title: Text('Date: ${date.toLocal()}'),
//                           subtitle: Text('Status: $dateStatus'),
//                           trailing: PopupMenuButton<String>(
//                             onSelected: isCurrentDate
//                                 ? (value) async {
//                                     print("daily order id");
//                                     print(dateData['dailyOrderId']);
//                                     await changeDateStatus(
//                                         context, // Pass context here
//                                         orderId,
//                                         dateData['date'],
//                                         value,
//                                         dateData['dailyOrderId'],
//                                         userDetails);
//                                   }
//                                 : null,
//                             itemBuilder: (context) => [
//                               if (dateStatus == 'pending' &&
//                                   dateStatus != "Cancel")
//                                 const PopupMenuItem<String>(
//                                   value: 'Preparing',
//                                   child: Text('Preparing'),
//                                 ),
//                               if (dateStatus == 'Preparing' &&
//                                   dateStatus != "Cancel")
//                                 const PopupMenuItem<String>(
//                                   value: 'Shipped',
//                                   child: Text('Shipped'),
//                                 ),
//                               if (dateStatus == 'Shipped' &&
//                                   dateStatus != "Cancel")
//                                 const PopupMenuItem<String>(
//                                   value: 'Completed',
//                                   child: Text('Completed'),
//                                 ),
//                               if (dateStatus == 'pending')
//                                 const PopupMenuItem<String>(
//                                   value: 'Cancel',
//                                   child: Text('Cancel'),
//                                 ),
//                             ],
//                           ),
//                           enabled:
//                               isCurrentDate, // Disable if it's not the current date
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//                 trailing: PopupMenuButton<String>(
//                   onSelected: (value) async {
//                     if (value == 'cancel') {
//                       await cancelOrder(orderId);
//                     } else {
//                       await changeOrderStatus(
//                           context, orderId, value); // Pass context here
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     if (widget.status != 'cancelled')
//                       const PopupMenuItem<String>(
//                         value: 'cancel',
//                         child: Text('Cancel Order'),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void fetchUserDetails(String userId) async {
//     AuthController authController = Get.put(AuthController());
//     UserDetailsModel userDetails =
//         await authController.fetchUserDatabypassUserId(userId);
//     print("User data for pin:");
//     print(userDetails.orderpin);

//     setState(() {
//       this.userDetails = userDetails;
//       userCache[userId] = userDetails; // Cache the user details
//     });

//     if (userCache.containsKey(userId)) {
//       setState(() {
//         userDetails = userCache[userId]!;
//       });
//       return;
//     }
//   }

//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

//   Future<bool> _showConfirmationDialog(
//       BuildContext context, String title, String message) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible:
//               false, // User must tap a button to close the dialog
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text(title),
//               content: Text(message),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(false); // User cancels
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(true); // User confirms
//                   },
//                   child: const Text('Confirm'),
//                 ),
//               ],
//             );
//           },
//         ) ??
//         false; // Default to false if dialog is dismissed without action
//   }

//   Future<void> changeOrderStatus(
//       BuildContext context, String orderId, String newStatus) async {
//     try {
//       bool confirm = await _showConfirmationDialog(
//           context,
//           'Change Order Status',
//           'Are you sure you want to change the order status to $newStatus?');
//       if (confirm) {
//         DateTime currentTime = DateTime.now();
//         await FirebaseFirestore.instance
//             .collection('difwa-orders')
//             .doc(orderId)
//             .set({
//           'statusHistory': FieldValue.arrayUnion([
//             {
//               'status': newStatus,
//               'timestamp': currentTime,
//             }
//           ]),
//         });
//         print('Order status updated successfully');
//       }
//     } catch (e) {
//       print('Error updating order status: $e');
//     }
//   }

//   Future<void> changeDateStatus(
//       BuildContext context,
//       String orderId,
//       String date,
//       String newStatus,
//       String dailyOrderId,
//       UserDetailsModel usersData) async {
//     try {
//       String pin;
//       if (newStatus == "Completed") {
//         print("PRI :: $newStatus");
//         print("PIN :: ${usersData.orderpin}");
//         pin = await _showPinDialog(context);
//         if (usersData.orderpin == pin) {
//           print("PRI3 :: $pin");
//         } else {
//           _showErrorDialog(context, "Entered pipn is wrong ",
//               "Please insure your pin is correct");
//           return;
//         }
//       } else {
//         print("PRI1 :: $newStatus");
//       }

//       bool confirm = await _showConfirmationDialog(
//           context,
//           'Change Date Status',
//           'Are you sure you want to change the status of the date to $newStatus?');
//       if (confirm) {
//         DateTime currentTime = DateTime.now();
//         final orderDoc =
//             FirebaseFirestore.instance.collection('difwa-orders').doc(orderId);
//         final orderSnapshot = await orderDoc.get();

//         if (!orderSnapshot.exists) {
//           print('Order not found');
//           return;
//         }

//         final orderData = orderSnapshot.data() as Map<String, dynamic>;

//         if (orderData['selectedDates'] == null ||
//             orderData['selectedDates'] is! List) {
//           print('Selected dates not found or invalid');
//           return;
//         }

//         final selectedDates =
//             List<Map<String, dynamic>>.from(orderData['selectedDates']);

//         // Find the index of the date in selectedDates list based on dailyOrderId
//         final dateIndex = selectedDates
//             .indexWhere((item) => item['dailyOrderId'] == dailyOrderId);

//         // If the date is found, update the status and add to statusHistory
//         if (dateIndex != -1) {
//           selectedDates[dateIndex]['status'] = newStatus;
//           // Update the status for the specific date
//           selectedDates[dateIndex]['statusHistory']['status'] = newStatus;

//           if (selectedDates[dateIndex]['statusHistory'] == null) {
//             selectedDates[dateIndex]['statusHistory'] = {};
//           }

//           selectedDates[dateIndex]['statusHistory']['${newStatus}Time'] =
//               currentTime;

//           await orderDoc.update({
//             'selectedDates': selectedDates,
//           });

//           print('Order date status updated successfully');
//         } else {
//           print(
//               'Date with dailyOrderId $dailyOrderId not found in selectedDates');
//         }
//       }
//     } catch (e) {
//       print('Error updating date status: $e');
//     }
//   }

//   Future<void> cancelOrder(String orderId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('difwa-orders')
//           .doc(orderId)
//           .update({
//         'status': 'cancelled',
//         'statusHistory': FieldValue.arrayUnion([
//           {
//             'status': 'cancelled',
//             'timestamp': FieldValue.serverTimestamp(),
//           }
//         ]),
//       });
//     } catch (e) {
//       print('Error cancelling order: $e');
//     }
//   }

//   Future<String> _showPinDialog(BuildContext context) async {
//     TextEditingController pinController = TextEditingController();
//     String enteredPin = '';

//     // Show a dialog to enter pin
//     await showDialog<String>(
//       context: context,
//       barrierDismissible: false, // User must tap a button to close the dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Enter Pin to Complete Order'),
//           content: TextField(
//             controller: pinController,
//             obscureText: true, // Obscure the input for pin security
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(hintText: 'Enter your pin'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 enteredPin = pinController.text.trim();
//                 Navigator.of(context).pop(enteredPin); // Return the entered pin
//               },
//               child: const Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );

//     return enteredPin;
//   }

//   Future<void> _showErrorDialog(
//       BuildContext context, String title, String message) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // User must tap a button to close the dialog
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
