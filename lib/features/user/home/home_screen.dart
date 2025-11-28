import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/controller/user_controller.dart';
import 'package:difwa_app/features/user/home/controller/home_user_controller.dart';
import 'package:difwa_app/features/user/home/vendor_details_screen.dart';
import 'package:difwa_app/features/user/home/widgets/booking_bottom_sheet.dart';
import 'package:difwa_app/features/user/home/widgets/home_app_bar.dart';
import 'package:difwa_app/features/user/home/widgets/item_card.dart';
import 'package:difwa_app/features/user/home/widgets/wallet_banner.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:difwa_app/features/orders/controller/checkout_controller.dart';
import 'package:difwa_app/features/orders/models/order_model.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onWalletPressed;
  final VoidCallback onNotificationPressed;
  const HomeScreen({
    super.key,
    required this.onWalletPressed,
    required this.onNotificationPressed,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final HomeUserController _homeController = Get.put(HomeUserController());
  final AddressController addressController = Get.put(AddressController());
  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // No need to fetch user data manually, UserController handles it
  }



  void _showBookingBottomSheet(
    VendorModel vendor,
    Map<String, dynamic> itemData,
  ) {
    final checkoutController = Get.put(CheckoutController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        itemData: itemData,
        walletBalance: _userController.user.value?.walletBalance ?? 0.0,
        onConfirm: (quantity, hasEmptyBottle, date, timeSlot) async {
          Navigator.pop(context);

          final user = _userController.user.value;
          if (user == null) {
            Get.snackbar('Error', 'User data not found');
            return;
          }

          double price = (itemData['price'] ?? 0).toDouble();
          double emptyBottlePrice = (itemData['emptyBottlePrice'] ?? 0).toDouble();
          double totalAmount = (price * quantity);
          if (hasEmptyBottle) {
            totalAmount += (emptyBottlePrice * quantity);
          }

          if (user.walletBalance < totalAmount) {
            _showInsufficientBalanceDialog();
            return;
          }

          final order = OrderModel(
            orderId: const Uuid().v4(),
            userId: user.uid,
            userName: user.name,
            userMobile: user.number,
            vendorId: vendor.merchantId,
            vendorName: vendor.vendorName,
            itemName: itemData['name'] ?? 'Water Can',
            itemPrice: price,
            quantity: quantity,
            hasEmptyBottle: hasEmptyBottle,
            orderDate: DateTime.now(),
            selectedDate: date,
            timeSlot: timeSlot,
            paymentStatus: 'paid',
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

  void _showInsufficientBalanceDialog() {
    Get.defaultDialog(
      title: "Insufficient Balance",
      middleText:
          "Your wallet balance is insufficient for this order. Please add money to your wallet.",
      textConfirm: "Add Money",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        Get.toNamed(AppRoutes.addbalance_screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Obx(() {
          final currentAddress = addressController.selectedAddress.value;
          final addressString = currentAddress != null
              ? '${currentAddress.street}, ${currentAddress.city}'
              : 'Select Location';

          return HomeAppBar(
            user: _userController.user.value,
            currentAddress: addressString,

            onWalletPressed: widget.onWalletPressed,
            onNotificationPressed: () => Get.toNamed(AppRoutes.notification),
            onLocationPressed: () {
              _showAddressSelectionDialog();
            },
          );
        }),
      ),
      body: Obx(() {
        if (_homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Banner
              Obx(() => WalletBanner(
                currentBalance: _userController.user.value?.walletBalance ?? 0.0,
                onBuyNowPressed: () {
                  Get.toNamed(AppRoutes.addbalance_screen);
                },
              )),

              const SizedBox(height: 16),

              // Filters - Dynamic from controller
              if (_homeController.availableSizes.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        _homeController.availableSizes.length +
                        1, // +1 for "All"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "All" option
                        final isSelected =
                            _homeController.selectedSize.value == null;
                        return GestureDetector(
                          onTap: () => _homeController.updateSelectedSize(null),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.grey[400]!)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'All',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }

                      final size = _homeController.availableSizes[index - 1];
                      final isSelected =
                          _homeController.selectedSize.value == size;
                      return GestureDetector(
                        onTap: () => _homeController.updateSelectedSize(size),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.grey[400]!)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$size L',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Available Items Header
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Available Items (${_homeController.filteredItems.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Item List
              if (_homeController.filteredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No items found.")),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _homeController.filteredItems.length,
                  itemBuilder: (context, index) {
                    final itemData = _homeController.filteredItems[index];
                    final vendor = itemData['vendor'] as VendorModel;

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => VendorDetailsScreen(
                            vendor: vendor,
                            vendorItems: _homeController.filteredItems
                                .where(
                                  (item) =>
                                      item['vendorId'] == vendor.merchantId,
                                )
                                .toList(),
                          ),
                        );
                      },
                      child: ItemCard(
                        itemData: itemData,
                        onBookNowPressed: () =>
                            _showBookingBottomSheet(vendor, itemData),
                        onSubscribePressed: () =>
                            _showSubscriptionBottomSheet(vendor, itemData),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _showSubscriptionBottomSheet(
    VendorModel vendor,
    Map<String, dynamic> itemData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        itemData: itemData,
        walletBalance: _userController.user.value?.walletBalance ?? 0.0,
        isSubscription: true,
        onConfirm: (quantity, hasEmptyBottle, date, timeSlot) {
          Navigator.pop(context);

          // Prepare data for subscription screen
          final subscriptionData = Map<String, dynamic>.from(itemData);
          subscriptionData['quantity'] = quantity;
          subscriptionData['hasEmptyBottle'] = hasEmptyBottle;
          // Ensure vendor info is present
          if (!subscriptionData.containsKey('vendor')) {
            subscriptionData['vendor'] = vendor;
            subscriptionData['vendorName'] = vendor.vendorName;
            subscriptionData['vendorId'] = vendor.merchantId;
          }
          subscriptionData['bottle'] = itemData;

          // Navigate to Subscription Screen
          Get.toNamed(
            AppRoutes.subscription,
            arguments: subscriptionData,
          );
        },
      ),
    );
  }

  void _showAddressSelectionDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Delivery Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: addressController.addressList.length,
                  itemBuilder: (context, index) {
                    final address = addressController.addressList[index];
                    final isSelected =
                        address.docId ==
                        addressController.selectedAddress.value?.docId;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(address.locationType.toUpperCase()),
                      subtitle: Text('${address.street}, ${address.city}'),
                      onTap: () {
                        addressController.selectAddress(address.docId);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
