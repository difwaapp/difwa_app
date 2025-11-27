
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/features/user/home/widgets/booking_bottom_sheet.dart';
import 'package:difwa_app/features/user/home/widgets/item_card.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:difwa_app/features/orders/controller/checkout_controller.dart';
import 'package:difwa_app/features/orders/models/order_model.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class VendorDetailsScreen extends StatefulWidget {
  final VendorModel vendor;
  final List<Map<String, dynamic>> vendorItems;

  const VendorDetailsScreen({
    super.key,
    required this.vendor,
    required this.vendorItems,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  final FirebaseService _fs = Get.find();
  AppUser? usersData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AppUser? appUser = await _fs.fetchAppUser(user.uid);
        if (mounted) {
          setState(() {
            usersData = appUser;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void _showBookingBottomSheet(Map<String, dynamic> itemData) {
    final checkoutController = Get.put(CheckoutController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        itemData: itemData,
        walletBalance: usersData?.walletBalance ?? 0.0,
        onConfirm: (quantity, hasEmptyBottle, date, timeSlot) async {
          Navigator.pop(context);

          if (usersData == null) {
            Get.snackbar('Error', 'User data not found');
            return;
          }

          double price = (itemData['price'] ?? 0).toDouble();
          double emptyBottlePrice = (itemData['emptyBottlePrice'] ?? 0).toDouble();
          double totalAmount = (price * quantity);
          if (hasEmptyBottle) {
            totalAmount += (emptyBottlePrice * quantity);
          }

          final order = OrderModel(
            orderId: const Uuid().v4(),
            userId: usersData!.uid,
            userName: usersData!.name,
            userMobile: usersData!.number,
            vendorId: widget.vendor.merchantId,
            vendorName: widget.vendor.vendorName,
            itemName: itemData['name'] ?? 'Water Can',
            itemPrice: price,
            quantity: quantity,
            hasEmptyBottle: hasEmptyBottle,
            orderDate: DateTime.now(),
            selectedDate: date,
            timeSlot: timeSlot,
            paymentStatus: 'paid', // Assuming wallet payment
            totalAmount: totalAmount,
            walletUsed: totalAmount,
            orderStatus: 'pending',
            deliveryOtp: checkoutController.generateOtp(),
            selectedDates: [
              {
                'date': date.toIso8601String(),
                'status': 'pending',
                'dailyOrderId': const Uuid().v4(),
                'statusHistory': {
                  'status': 'pending',
                  'timestamp': DateTime.now(),
                }
              }
            ],
          );

          await checkoutController.placeOrder(order);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Vendor Header
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: appTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Vendor Image/Cover
                  if (widget.vendor.images.containsKey('store'))
                    Image.network(
                      widget.vendor.images['store']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300]);
                      },
                    )
                  else
                    Container(color: appTheme.primaryColor),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),

                  // Vendor Info
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendor.vendorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "4.5", // Placeholder rating
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.vendor.areaCity}, ${widget.vendor.state}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final itemData = widget.vendorItems[index];
                  // Ensure vendor info is passed
                  if (!itemData.containsKey('vendor')) {
                    itemData['vendor'] = widget.vendor;
                    itemData['vendorName'] = widget.vendor.vendorName;
                    itemData['vendorId'] = widget.vendor.merchantId;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ItemCard(
                      itemData: itemData,
                      onBookNowPressed: () => _showBookingBottomSheet(itemData),
                      onSubscribePressed: () => _showSubscriptionBottomSheet(itemData),
                    ),
                  );
                },
                childCount: widget.vendorItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionBottomSheet(Map<String, dynamic> itemData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        itemData: itemData,
        walletBalance: usersData?.walletBalance ?? 0.0,
        isSubscription: true,
        onConfirm: (quantity, hasEmptyBottle, date, timeSlot) {
          Navigator.pop(context);
          
          // Prepare data for subscription screen
          final subscriptionData = Map<String, dynamic>.from(itemData);
          subscriptionData['quantity'] = quantity;
          subscriptionData['hasEmptyBottle'] = hasEmptyBottle;
          subscriptionData['bottle'] = itemData; // Ensure bottle data is nested as expected by SubscriptionScreen
          
          // Navigate to Subscription Screen
          Get.toNamed(
            '/subscription', // Use route name string directly or AppRoutes.subscription if imported
            arguments: subscriptionData,
          );
        },
      ),
    );
  }
}
