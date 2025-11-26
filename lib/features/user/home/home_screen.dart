import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/features/user/home/controller/home_user_controller.dart';
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
  final FirebaseService _fs = Get.find();
  final HomeUserController _homeController = Get.put(HomeUserController());
  final AddressController addressController = Get.put(AddressController());
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

  void _showBookingBottomSheet(
    VendorModel vendor,
    Map<String, dynamic> itemData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        itemData: itemData,
        walletBalance: usersData?.walletBalance ?? 0.0,
        onConfirm: (quantity, hasEmptyBottle, date, timeSlot) {
          Navigator.pop(context);
          Get.snackbar(
            'Success',
            'Order placed successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
      ),
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
            user: usersData,
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
              WalletBanner(
                currentBalance: usersData?.walletBalance ?? 0.0,
                onBuyNowPressed: () {
                  Get.toNamed(AppRoutes.addbalance_screen);
                },
              ),

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

                    return ItemCard(
                      itemData: itemData,
                      onBookNowPressed: () =>
                          _showBookingBottomSheet(vendor, itemData),
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
