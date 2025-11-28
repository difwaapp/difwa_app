import 'dart:async';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/features/orders/models/order_model.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/features/vendor/profile/verndor_profile_screen.dart';
import 'package:difwa_app/features/vendor/store/store_screen.dart';
import 'package:difwa_app/features/vendor/home/vendor_home_screen.dart';
import 'package:difwa_app/features/vendor/orders_recieved/order_recieved_screen.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

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
  final FirebaseService _fs = Get.find();
  AppUser? usersData;
  bool isLoading = true;
  bool isSwitched = false;
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


  Future<AppUser?> getUserData(String uid) async {
    try {
      // Only call setState if we're in the main widget context, not in a dialog
      if (mounted && context.mounted) {
        setState(() => isLoading = true);
      }
      print('Fetching user data...');

      AppUser? user = await _fs.fetchAppUser(uid);
      print('User data fetched successfully');
      
      if (mounted && context.mounted) {
        setState(() => isLoading = false);
      }
      return user;
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted && context.mounted) {
        setState(() => isLoading = false);
      }
      return null;
    }
  }

  // Fetch user data without setState - for use in dialogs
  Future<AppUser?> getUserDataForDialog(String uid) async {
    try {
      print('Fetching user data for dialog...');
      AppUser? user = await _fs.fetchAppUser(uid);
      print('User data fetched successfully for dialog');
      return user;
    } catch (e) {
      print('Error fetching user data for dialog: $e');
      return null;
    }
  }

  // Fetch user's selected address from address subcollection
  Future<Address?> getSelectedAddress(String userId) async {
    try {
      print('Fetching selected address for user: $userId');
      
      final addressSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('address')
          .where('isSelected', isEqualTo: true)
          .limit(1)
          .get();

      if (addressSnapshot.docs.isNotEmpty) {
        final addressData = addressSnapshot.docs.first.data();
        print('Selected address found: ${addressData['street']}, ${addressData['city']}');
        print('DEBUG: Full address data: $addressData');
        
        // Use Address model to parse the data
        final address = Address.fromMap(addressData);
        print('DEBUG: Parsed address - street: ${address.street}, city: ${address.city}, state: ${address.state}');
        print('DEBUG: Parsed address - lat: ${address.latitude}, lng: ${address.longitude}');
        return address;
      } else {
        print('No selected address found');
        return null;
      }
    } catch (e) {
      print('Error fetching selected address: $e');
      print('DEBUG: Error stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Helper method to format Address object into readable string
  String _formatAddress(Address? address) {
    if (address == null) {
      print('_formatAddress: address is null');
      return 'No address selected';
    }
    
    print('_formatAddress called with: street=${address.street}, floor=${address.floor}, city=${address.city}, state=${address.state}, country=${address.country}');
    
    List<String> addressParts = [];
    if (address.floor.isNotEmpty) addressParts.add('Floor: ${address.floor}');
    if (address.street.isNotEmpty) addressParts.add(address.street);
    if (address.city.isNotEmpty) addressParts.add(address.city);
    if (address.state.isNotEmpty) addressParts.add(address.state);
    if (address.country.isNotEmpty) addressParts.add(address.country);
    
    String result = addressParts.isNotEmpty ? addressParts.join(', ') : 'Address details not available';
    print('_formatAddress result: $result');
    return result;
  }

  // Helper method to open map with coordinates
  Future<void> _openMap(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri uri = Uri.parse(googleMapsUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch map URL: $googleMapsUrl');
        Get.snackbar(
          'Error',
          'Could not open map application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error launching map: $e');
      Get.snackbar(
        'Error',
        'Failed to open map: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Calculate distance between two coordinates in kilometers
  String calculateDistance(double? vendorLat, double? vendorLng, double? customerLat, double? customerLng) {
    if (vendorLat == null || vendorLng == null || customerLat == null || customerLng == null) {
      return 'N/A';
    }
    
    try {
      double distanceInMeters = Geolocator.distanceBetween(
        vendorLat,
        vendorLng,
        customerLat,
        customerLng,
      );
      
      double distanceInKm = distanceInMeters / 1000;
      
      if (distanceInKm < 1) {
        return '${distanceInMeters.toStringAsFixed(0)} m';
      } else {
        return '${distanceInKm.toStringAsFixed(2)} km';
      }
    } catch (e) {
      print('Error calculating distance: $e');
      return 'N/A';
    }
  }

  void _listenForNewOrders() {
    if (merchantIdd.isEmpty) {
      print("DEBUG: Merchant ID is empty. Cannot listen for orders.");
      return;
    }
    print("DEBUG: Listening for new orders for merchantId: $merchantIdd");

    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('merchantId', isEqualTo: merchantIdd)
        .where('orderStatus', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snapshot) {
            print(
              "DEBUG: Snapshot received. Docs count: ${snapshot.docs.length}",
            );

            if (snapshot.docs.isNotEmpty) {
              var orderDoc = snapshot.docs.first;
              Map<String, dynamic> orderMap = orderDoc.data();

              // Parse using OrderModel.fromMap()
              OrderModel orderData = OrderModel.fromMap(orderMap);
              
              print("DEBUG: New order found: ${orderData.orderId}");
              print("DEBUG: Order Status: ${orderData.orderStatus}");

              // Pass both orderData and orderMap for address access
              _showPopup(context, orderData, orderMap);

              if (!_isVibrating) {
                print("DEBUG: Starting vibration...");
                _startVibration();
              }
              if (!_isSoundPlaying) {
                print("DEBUG: Starting sound...");
                _startSound();
              }
            } else {
              print("DEBUG: No pending orders found");
            }
          },
          onError: (error) {
            print("DEBUG: Error while listening to Firestore: $error");
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
    try {
      await _audioPlayer.setSource(AssetSource('audio/zomato_ring_5.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.play(AssetSource('audio/zomato_ring_5.mp3'));
      _isSoundPlaying = true;
    } catch (e) {
      print("Error playing sound: $e");
    }
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

  void _updateOrderStatus(String orderId, String status) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).get().then((
      doc,
    ) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> selectedDates =
            (data['selectedDates'] as List<dynamic>?) ?? [];

        // Update status for all dates if confirming the order
        if (status == 'confirmed') {
          for (var date in selectedDates) {
            date['status'] = 'confirmed';
            // Initialize or update statusHistory as a Map
            Map<String, dynamic> history =
                (date['statusHistory'] as Map<String, dynamic>?) ?? {};
            history['confirmedTime'] = Timestamp.now();
            history['status'] =
                'confirmed'; // Also update current status in history if needed
            date['statusHistory'] = history;
          }
        } else if (status == 'cancelled') {
          for (var date in selectedDates) {
            date['status'] = 'cancelled';
            Map<String, dynamic> history =
                (date['statusHistory'] as Map<String, dynamic>?) ?? {};
            history['cancelledTime'] = Timestamp.now();
            history['status'] = 'cancelled';
            date['statusHistory'] = history;
          }
        }

        doc.reference
            .update({'orderStatus': status, 'selectedDates': selectedDates})
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
          heroTag: 'vendor_dashboard_fab',
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

  bool _isPopupShown = false;

  // Show full-screen popup with order details, user information, and delivery address
  void _showPopup(
    BuildContext context,
    OrderModel orderData,
    Map<String, dynamic> orderMap,
  ) {
    if (_isPopupShown) return;
    _isPopupShown = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              getUserDataForDialog(orderData.userId).catchError((e) {
                print('ERROR in getUserDataForDialog: $e');
                return null;
              }),
              getSelectedAddress(orderData.userId).catchError((e) {
                print('ERROR in getSelectedAddress: $e');
                return null;
              }),
              _VendorsController.fetchStoreData().catchError((e) {
                print('ERROR in fetchStoreData: $e');
                return null;
              }),
            ]),
            builder: (context, snapshot) {
              print('DEBUG: FutureBuilder state - connectionState: ${snapshot.connectionState}');
              print('DEBUG: FutureBuilder hasData: ${snapshot.hasData}');
              print('DEBUG: FutureBuilder hasError: ${snapshot.hasError}');
              if (snapshot.hasError) {
                print('DEBUG: FutureBuilder error: ${snapshot.error}');
              }
              if (snapshot.hasData) {
                print('DEBUG: FutureBuilder data length: ${snapshot.data!.length}');
                print('DEBUG: FutureBuilder data[0] (userData): ${snapshot.data![0]}');
                print('DEBUG: FutureBuilder data[1] (deliveryAddress): ${snapshot.data![1]}');
                print('DEBUG: FutureBuilder data[2] (vendorData): ${snapshot.data![2]}');
              }
              
              final AppUser? userData = snapshot.hasData && snapshot.data!.isNotEmpty 
                  ? snapshot.data![0] as AppUser? 
                  : null;
              final Address? deliveryAddress = snapshot.hasData && snapshot.data!.length > 1
                  ? snapshot.data![1] as Address? 
                  : null;
              final VendorModel? vendorData = snapshot.hasData && snapshot.data!.length > 2
                  ? snapshot.data![2] as VendorModel?
                  : null;
              
              print('DEBUG: userData is null: ${userData == null}');
              print('DEBUG: deliveryAddress is null: ${deliveryAddress == null}');
              print('DEBUG: vendorData is null: ${vendorData == null}');
              if (deliveryAddress != null) {
                print('DEBUG: deliveryAddress street: ${deliveryAddress.street}, city: ${deliveryAddress.city}');
              }
              if (vendorData != null) {
                print('DEBUG: vendorData lat: ${vendorData.latitude}, lng: ${vendorData.longitude}');
              }
              
              // Calculate distance if both coordinates are available
              String distance = 'N/A';
              if (vendorData != null && deliveryAddress != null) {
                distance = calculateDistance(
                  vendorData.latitude,
                  vendorData.longitude,
                  deliveryAddress.latitude,
                  deliveryAddress.longitude,
                );
                print('DEBUG: Calculated distance: $distance');
              }

              return SafeArea(
                  child: Column(
                    children: [
                      // Gradient Header with Customer Info
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                          ),
                        ),
                        child: Column(
                          children: [
                            // Top bar with notification icon and swipe hint
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'New Order Alert!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Review order details and take action',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Customer Profile Section
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: snapshot.connectionState == ConnectionState.waiting
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        // Profile Image
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.white,
                                          backgroundImage: userData?.profileImage != null &&
                                                  userData!.profileImage!.isNotEmpty
                                              ? NetworkImage(userData.profileImage!)
                                              : null,
                                          child: userData?.profileImage == null ||
                                                  (userData?.profileImage != null && userData!.profileImage!.isEmpty)
                                              ? Text(
                                                  (userData?.name ?? orderData.userName)
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1565C0),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userData?.name ?? orderData.userName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    color: Colors.white70,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    userData?.number ?? orderData.userMobile,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (userData?.email != null) ...[
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.email,
                                                      color: Colors.white70,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        userData!.email,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Delivery Address Section - PROMINENT
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Delivery Location',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: snapshot.connectionState == ConnectionState.waiting
                                          ? Row(
                                              children: const [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Loading address...'),
                                              ],
                                            )
                                          : deliveryAddress == null
                                              ? Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color: Colors.orange,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'No delivery address selected by customer',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Icon(
                                                          Icons.place,
                                                          color: Colors.orange,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            _formatAddress(deliveryAddress),
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              color: Colors.black87,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Distance display
                                                    if (distance != 'N/A') ...[
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.shade50,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: Colors.blue.shade200,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.social_distance,
                                                              size: 16,
                                                              color: Colors.blue.shade700,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'Distance: $distance',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.blue.shade700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    if (deliveryAddress.latitude != null && 
                                                        deliveryAddress.longitude != null) ...[
                                                      const SizedBox(height: 12),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton.icon(
                                                          onPressed: () {
                                                            _openMap(
                                                              deliveryAddress.latitude!,
                                                              deliveryAddress.longitude!,
                                                            );
                                                          },
                                                          icon: const Icon(Icons.map, size: 18),
                                                          label: const Text('Navigate to Map'),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.orange,
                                                            foregroundColor: Colors.white,
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 16,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Order Details Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1565C0).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_bag,
                                            color: Color(0xFF1565C0),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Order Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _buildDetailRow('Item', orderData.itemName, Icons.water_drop),
                                    _buildDetailRow(
                                      'Quantity',
                                      '${orderData.quantity} units',
                                      Icons.shopping_cart,
                                    ),
                                    _buildDetailRow(
                                      'Price/Unit',
                                      '₹${orderData.itemPrice.toStringAsFixed(2)}',
                                      Icons.currency_rupee,
                                    ),
                                    const Divider(height: 20),
                                    _buildDetailRow(
                                      'Total Amount',
                                      '₹${orderData.totalAmount.toStringAsFixed(2)}',
                                      Icons.payments,
                                      isHighlighted: true,
                                    ),
                                    if (orderData.walletUsed > 0)
                                      _buildDetailRow(
                                        'Wallet Used',
                                        '₹${orderData.walletUsed.toStringAsFixed(2)}',
                                        Icons.account_balance_wallet,
                                        valueColor: Colors.orange,
                                      ),
                                    const Divider(height: 20),
                                    _buildDetailRow('Time Slot', orderData.timeSlot, Icons.access_time),
                                    _buildDetailRow('Payment', orderData.paymentStatus, Icons.payment),
                                    if (orderData.hasEmptyBottle)
                                      _buildDetailRow(
                                        'Empty Bottle Return',
                                        'Yes',
                                        Icons.recycling,
                                        valueColor: Colors.green,
                                      ),
                                    if (orderData.isSubscription) ...[
                                      const Divider(height: 20),
                                      _buildDetailRow(
                                        'Subscription',
                                        orderData.subscriptionFrequency ?? 'N/A',
                                        Icons.repeat,
                                        valueColor: Colors.purple,
                                      ),
                                      if (orderData.subscriptionDays != null)
                                        _buildDetailRow(
                                          'Duration',
                                          '${orderData.subscriptionDays} days',
                                          Icons.calendar_today,
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Order ID Card
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tag, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Order ID: ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        orderData.orderId,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vertical Slide Actions at Bottom
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Accept Order Slide Action (Top)
                            SlideAction(
                              borderRadius: 12,
                              elevation: 2,
                              innerColor: Colors.white,
                              outerColor: Colors.green,
                              sliderButtonIcon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.green,
                                size: 14,
                              ),
                              text: 'Slide to Accept Order',
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              onSubmit: () {
                                _stopVibration();
                                _stopSound();
                                Navigator.of(dialogContext).pop();

                                Future(() async {
                                  _updateOrderStatus(orderData.orderId, 'confirmed');
                                  _paymentHistoryController.savePaymentHistory(
                                    orderData.totalAmount,
                                    "Credited",
                                    orderData.userId,
                                    "payment id",
                                    "Done",
                                    "",
                                  );

                                  VendorModel? storedata =
                                      await _VendorsController.fetchStoreData();
                                  double previousEarnings = storedata?.earnings ?? 0.0;

                                  double addedmoney =
                                      orderData.totalAmount + previousEarnings;
                                  await _VendorsController.updateStoreDetails({
                                    "earnings": addedmoney,
                                  });
                                });
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            // Decline Order Slide Action (Bottom)
                            SlideAction(
                              borderRadius: 12,
                              elevation: 2,
                              innerColor: Colors.white,
                              outerColor: Colors.red,
                              sliderButtonIcon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.red,
                                size: 14,
                              ),
                              text: 'Slide to Decline Order',
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              onSubmit: () {
                                _stopVibration();
                                _stopSound();
                                Navigator.of(dialogContext).pop();

                                _updateOrderStatus(orderData.orderId, 'cancelled');
                                _paymentHistoryController.savePaymentHistory(
                                  orderData.totalAmount,
                                  "Canceled",
                                  orderData.userId,
                                  "payment id",
                                  "Cancel",
                                  "",
                                );
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              );
            },
          ),
        );
      },
    ).then((_) {
      _isPopupShown = false;
      _stopVibration();
      _stopSound();
    });
  }

  // Helper widget to build detail rows
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isHighlighted ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isHighlighted ? Colors.green.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Old helper method - keeping for backward compatibility
  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
