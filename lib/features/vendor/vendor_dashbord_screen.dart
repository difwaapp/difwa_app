import 'dart:async';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/features/vendor/profile/verndor_profile_screen.dart';
import 'package:difwa_app/features/vendor/store/store_screen.dart';
import 'package:difwa_app/features/vendor/home/vendor_home_screen.dart';
import 'package:difwa_app/features/vendor/orders_recieved/order_recieved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class VendorDashbordScreen extends StatefulWidget {
  const VendorDashbordScreen({super.key});

  @override
  _VendorDashbordScreenState createState() => _VendorDashbordScreenState();
}

class _VendorDashbordScreenState extends State<VendorDashbordScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late StreamSubscription _orderSubscription;
  final FirebaseController _authController = Get.put(FirebaseController());
  final VendorsController _VendorsController = Get.put(VendorsController());
  final PaymentHistoryController _paymentHistoryController = Get.put(
    PaymentHistoryController(),
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  String merchantIdd = "";

  late bool _isVibrating;
  late bool _isSoundPlaying;

  @override
  void initState() {
    super.initState();
    _screens = [
      const VendorHomeScreen(),
      const StoreScreen(),
      const OrderRecievedScreen(),
      const VerndorProfileScreen(),
    ];
    _authController.resolveMerchantId().then((merchantId) {
      setState(() {
        merchantIdd = merchantId;
      });
      _listenForNewOrders();
    });

    _isVibrating = false;
    _isSoundPlaying = false;
  }

  void _listenForNewOrders() {
    print("Listening for new orders for merchantId: $merchantIdd");

    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('merchantId', isEqualTo: merchantIdd)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snapshot) {
            print("Snapshot received: ${snapshot.docs.length} documents found");

            if (snapshot.docs.isNotEmpty) {
              var orderDoc = snapshot.docs.first;
              var orderData = orderDoc.data();

              print(
                "New order found with totalPrice: ${orderData['totalPrice']}",
              );

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
          },
          onError: (error) {
            print("Error while listening to Firestore: $error");
          },
        );
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

  void _updateOrderStatus(String status) {
    FirebaseFirestore.instance
        .collection('orders')
        .where('merchantId', isEqualTo: merchantIdd)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            var orderDoc = snapshot.docs.first;
            orderDoc.reference
                .update({'status': status})
                .then((_) {
                  print('Order status updated to $status');
                })
                .catchError((error) {
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

  Widget _navIcon(String assetPath, bool active, {double size = 24}) {
    final Color iconColor = active ? appTheme.primaryColor : Colors.black54;
    return AnimatedScale(
      scale: active ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        color: iconColor,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = appTheme.whiteColor;
    final primary = appTheme.primaryColor;
    final shadowColor = Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: appTheme.gray100,
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),

      // Floating action button in center (Flipkart-style)
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          onPressed: () {
            _onItemTapped(1);
          },
          elevation: 8,
          backgroundColor: primary,
          child: const Icon(
            Icons.water_drop_outlined,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: PhysicalShape(
          elevation: 8,
          color: bg,
          shadowColor: shadowColor,
          clipper: _NavBarClipper(),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Left two items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildItem(0, 'assets/icons/home.svg', 'Home'),
                      _buildItem(1, 'assets/icons/order.svg', 'Bottles'),
                    ],
                  ),
                ),
                // Spacer for center FAB notch
                const SizedBox(width: 10),
                // Right two items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildItem(2, 'assets/icons/wallet.svg', 'Orders'),
                      _buildItem(3, 'assets/icons/profile.svg', 'Profile'),
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

  Widget _buildItem(int index, String assetPath, String label) {
    final bool active = _selectedIndex == index;
    final Color primaryColor = appTheme.primaryColor;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navIcon(assetPath, active),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyleHelper.instance.customText(
                fontSize: active ? 12 : 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? primaryColor : Colors.black54,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // Show popup with order details
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
                        color: Colors.white,
                      ),
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
                            'User ID: ${orderData['uid']}',
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
                              orderData["uid"],
                              "payment id",
                              "Cancel",
                              orderData["bulkOrderId"],
                            );

                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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
                              orderData["uid"],
                              "payment id",
                              "Done",
                              orderData["bulkOrderId"],
                            );

                            VendorModal? storedata =
                                await _VendorsController.fetchStoreData();
                            double previousEarnings =
                                storedata?.earnings ?? 0.0;

                            double addedmoney = orderData["totalPrice"] + previousEarnings;
                            print("addedmoney");
                            print("storedata.earnings");
                            print("orderData");
                            print(addedmoney);
                            print(previousEarnings);
                            print(orderData["totalPrice"]);
                            await _VendorsController.updateStoreDetails({
                              "earnings": addedmoney,
                            });
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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

/// Clipper that leaves a centered notch for the FAB and rounds the bar.
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path p = Path();
    final double width = size.width;
    final double height = size.height;
    const double notchRadius = 36;
    const double notchWidth = notchRadius * 2 + 10;
    final double notchCenter = width / 2;

    // Start at left
    p.moveTo(0, 16);
    // left corner curve
    p.quadraticBezierTo(0, 0, 16, 0);
    // top line to before notch
    p.lineTo(notchCenter - notchWidth / 2 - 12, 0);
    // begin notch curve
    p.quadraticBezierTo(
      notchCenter - notchWidth / 2,
      0,
      notchCenter - notchWidth / 2 + 6,
      12,
    );
    p.arcToPoint(
      Offset(notchCenter + notchWidth / 2 - 6, 12),
      radius: Radius.circular(notchRadius + 6),
      clockwise: false,
    );
    p.quadraticBezierTo(
      notchCenter + notchWidth / 2,
      0,
      notchCenter + notchWidth / 2 + 12,
      0,
    );
    // continue top line to right corner
    p.lineTo(width - 16, 0);
    p.quadraticBezierTo(width, 0, width, 16);
    // right edge down
    p.lineTo(width, height - 16);
    p.quadraticBezierTo(width, height, width - 16, height);
    // bottom line
    p.lineTo(16, height);
    p.quadraticBezierTo(0, height, 0, height - 16);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
