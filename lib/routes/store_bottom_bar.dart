import 'dart:async';
import 'package:difwa_app/config/app_color.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/screens/stores_screens/order_new_screen.dart';
import 'package:difwa_app/screens/stores_screens/store_dashboard_new.dart';
import 'package:difwa_app/screens/stores_screens/store_items.dart';
import 'package:difwa_app/screens/stores_screens/store_profile_new.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class BottomStoreHomePage extends StatefulWidget {
  const BottomStoreHomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BottomStoreHomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late StreamSubscription _orderSubscription;
  final FirebaseController _authController = Get.put(FirebaseController());
  final VendorsController _VendorsController = Get.put(VendorsController());
  final PaymentHistoryController _paymentHistoryController =
      Get.put(PaymentHistoryController());

  final AudioPlayer _audioPlayer = AudioPlayer();
  String merchantIdd = "";

  late bool _isVibrating;
  late bool _isSoundPlaying;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const StoreItems(),
      OrdersScreen(),
      SupplierProfileScreen()
    ];
    _authController.fetchMerchantId("").then((merchantId) {
      setState(() {
        merchantIdd = merchantId!;
      });
      _listenForNewOrders();
    });

    _isVibrating = false;
    _isSoundPlaying = false;
  }

  void _listenForNewOrders() {
    print("Listening for new orders for merchantId: $merchantIdd");

    _orderSubscription = FirebaseFirestore.instance
        .collection('difwa-orders')
        .where('merchantId', isEqualTo: merchantIdd)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      print("Snapshot received: ${snapshot.docs.length} documents found");

      if (snapshot.docs.isNotEmpty) {
        var orderDoc = snapshot.docs.first;
        var orderData = orderDoc.data();

        print("New order found with totalPrice: ${orderData['totalPrice']}");

        _showPopup(context, orderData);

        if (!_isVibrating) {
          print("Starting vibration...");
          _startVibration();
        }
        if (!_isSoundPlaying) {
          print("Starting sound...");
          _startSound();
        }
      } else {
        print("No paid orders found");
      }
    }, onError: (error) {
      print("Error while listening to Firestore: $error");
    });
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator()) {
      _isVibrating = true;
      Vibration.vibrate(pattern: [500, 500], repeat: 0);
    }
  }

  void _startSound() async {
    await _audioPlayer.setSource(AssetSource('audio/zomato_ring_5.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/zomato_ring_5.mp3'));
    _isSoundPlaying = true;
  }

  void _stopVibration() {
    Vibration.cancel();
    _isVibrating = false;
  }

  void _stopSound() async {
    _audioPlayer.stop();
    _isSoundPlaying = false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // void _addPaymentHistory(String amount, String amountStatus, String userId,
  //     String paymentId, String paymentStatus, String bulkOrderId) {
  //   _paymentHistoryController.savePaymentHistory(
  //       amount, amountStatus, userId, paymentId, paymentStatus, bulkOrderId);
  // }

  void _updateOrderStatus(String status) {
    FirebaseFirestore.instance
        .collection('difwa-orders')
        .where('merchantId', isEqualTo: merchantIdd)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var orderDoc = snapshot.docs.first;
        orderDoc.reference.update({'status': status}).then((_) {
          print('Order status updated to $status');
        }).catchError((error) {
          print('Failed to update order status: $error');
        });
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription.cancel();
    if (_isVibrating) _stopVibration();
    if (_isSoundPlaying) _stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.whiteColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(color: Colors.blue),
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildSvgIcon(
                'assets/icons/home.svg', 'assets/icons/home_filled.svg', 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgIcon(
                'assets/icons/order.svg', 'assets/icons/order_filled.svg', 1),
            label: 'Bottles',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgIcon(
                'assets/icons/wallet.svg', 'assets/icons/wallet_filled.svg', 2),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/profile.svg',
                'assets/icons/profile_filled.svg', 3),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.inputfield,
      ),
    );
  }

  Widget _buildSvgIcon(String unselectedPath, String selectedPath, int index) {
    bool isSelected = _selectedIndex == index;

    return SvgPicture.asset(
      isSelected ? selectedPath : unselectedPath,
      width: isSelected ? 30 : 24,
      height: isSelected ? 30 : 24,
      colorFilter: ColorFilter.mode(
        isSelected ? AppColors.inputfield : Colors.black,
        BlendMode.srcIn,
      ),
    );
  }

  // Show popup with order detailssdfdsfsd
  void _showPopup(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.blueAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delivery_dining, size: 100, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'New Order Incoming!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Do you want to confirm or cancel?',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),

                    // Display order details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'Total Price: \$${orderData['totalPrice']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Size: ${orderData['bulkOrderId']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Quantity: ${orderData['quantity']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Order Status: ${orderData['status']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'User ID: ${orderData['userId']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Timestamp: ${orderData['timestamp']}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _stopVibration();
                            _stopSound();
                            _updateOrderStatus('canceled');
                            _paymentHistoryController.savePaymentHistory(
                                orderData["totalPrice"],
                                "Canceled",
                                orderData["userId"],
                                "payment id",
                                "Cancel",
                                orderData["bulkOrderId"]);

                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Cancel',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                        SizedBox(width: 20),
                        TextButton(
                          onPressed: () async {
                            _stopVibration();
                            _stopSound();
                            _updateOrderStatus('confirmed');
                            _paymentHistoryController.savePaymentHistory(
                                orderData["totalPrice"],
                                "Credited",
                                orderData["userId"],
                                "payment id",
                                "Done",
                                orderData["bulkOrderId"]);

                            VendorModal? storedata =
                                await _VendorsController.fetchStoreData();
                            double previousEarnings =
                                storedata?.earnings ?? 0.0;

                            double addedmoney =
                                orderData["totalPrice"] + previousEarnings;
                            print("addedmoney");
                            print("storedata.earnings");
                            print("orderData");
                            print(addedmoney);
                            print(previousEarnings);
                            print(orderData["totalPrice"]);
                            await _VendorsController.updateStoreDetails(
                                {"earnings": addedmoney});
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: Text('Confirm',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
