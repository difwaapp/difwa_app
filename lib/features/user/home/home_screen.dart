import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/user/checkout_screen.dart';
import 'package:difwa_app/features/user/store_details_screen.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/CustomPopup.dart';
import 'package:difwa_app/widgets/ImageCarouselApp.dart';
import 'package:difwa_app/widgets/custom_appbar.dart';
import 'package:difwa_app/widgets/order_details_component.dart';
import 'package:difwa_app/widgets/subscribe_button_component.dart';
import 'package:difwa_app/widgets/water_bottel_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/simmers/PackageSelectorShimmer .dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onMenuPressed;
  const HomeScreen({
    super.key,
    required this.onProfilePressed,
    required this.onMenuPressed,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _fs = Get.find();
  Map<String, dynamic>? _selectedPackage;
  int _selectedIndex = -1;
  bool _hasEmptyBottle = false;
  int _quantity = 1;
  double _totalPrice = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _bottleItems = [];
  List<VendorModal> _stores = [];
  String? _selectedMerchantId;

  final AuthController _userData = Get.put(AuthController());
  final VendorsController _vendorController = Get.put(VendorsController());

  AppUser? usersData;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchBottleItems();
  }

  void _fetchUserData() async {
    try {
      AppUser? user = await _fs.fetchAppUser(
        FirebaseAuth.instance.currentUser!.uid,
      );

      // if (mounted) {
      setState(() {
        _isLoading = false;
        usersData = user;
      });
      // }
    } catch (e) {
      // if (mounted) {F
      setState(() {
        _isLoading = false;
      });
      // }
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchBottleItems() async {
    try {
      Set<String> fetchedVendors = {};
      List<Map<String, dynamic>> fetchedItems = [];
      List<VendorModal> vendorList = [];

      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .get();

      for (var storeDoc in storeSnapshot.docs) {
        QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeDoc.id)
            .collection('items')
            .get();

        for (var doc in itemSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          String merchantId = data['merchantId'] ?? '';
          if (data['price'] == null || data['emptyBottlePrice'] == null) {
            print('Skipping item with missing price/emptyBottlePrice: $data');
            continue;
          }

          VendorModal? vendordata;
          if (!fetchedVendors.contains(merchantId)) {
            vendordata = await _vendorController.fetchStoreDataByMerchantId(
              merchantId,
            );
            if (vendordata != null) {
              fetchedVendors.add(merchantId);
              vendorList.add(vendordata);
            }
          } else {
            vendordata = vendorList.firstWhere(
              (v) => v.merchantId == merchantId,
            );
          }
          data['isActive'] = vendordata?.isActive;

          fetchedItems.add({
            'itemData': data,
            'vendorName': vendordata?.vendorName,
            'isActive': vendordata?.isActive,
          });
        }
      }

      if (mounted) {
        setState(() {
          _stores = vendorList;
          _bottleItems = fetchedItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load bottle data. Try again!")),
      );
    }
  }

  void _onPackageSelected(Map<String, dynamic>? package) {
    print(package);
    setState(() {
      _selectedPackage = package;
      _selectedIndex = _bottleItems.indexOf(package!);
    });
    _calculateTotalPrice(); // Ensure immediate total price update

    if (package != null) {
      _calculateTotalPrice(); // Ensure immediate total price update
    }
  }

  void _calculateTotalPrice() {
    if (_selectedIndex == -1) return;

    var bottle = _bottleItems[_selectedIndex]['itemData']; // Use selected index
    print('Selected bottle: $bottle');
    print('Quantity: $_quantity');
    print('Has empty bottle: $_hasEmptyBottle');

    // Safely convert price and emptyBottlePrice to double
    double price = (bottle['price'] ?? 0).toDouble(); // Convert to double
    double emptyBottlePrice = _hasEmptyBottle
        ? (bottle['emptyBottlePrice'] ?? 0).toDouble()
        : 0.0;

    print('Price per bottle: $price');
    print('Vacant price per bottle: $emptyBottlePrice');
    print(
      'Total price calculation: ${price * _quantity} + ($_quantity * $emptyBottlePrice)',
    );

    setState(() {
      _totalPrice = (price * _quantity) + (_quantity * emptyBottlePrice);
      print('Total price set: $_totalPrice');
    });
  }

  void _onSubscribePressed() {
    if (_selectedPackage != null && _selectedIndex != -1) {
      final itemData = _bottleItems[_selectedIndex]['itemData'];
      final price = (itemData['price'] ?? 0).toDouble();
      final emptyBottlePrice = _hasEmptyBottle
          ? (itemData['emptyBottlePrice'] ?? 0).toDouble()
          : 0.0;

      final Map<String, dynamic> myOrderData = {
        'bottle': itemData, // Use itemData directly
        'quantity': _quantity,
        'price': price,
        'emptyBottlePrice': emptyBottlePrice,
        'hasEmptyBottle': _hasEmptyBottle,
        'totalPrice': (price * _quantity) + (_quantity * emptyBottlePrice),
      };

      print("Data: $myOrderData");

      Get.toNamed(AppRoutes.subscription, arguments: myOrderData);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomPopup(
            title: "Oops! Bottle Not Selected",
            description:
                "Please select a bottle before moving forward. This ensures you get the best!",
            buttonText: "Got It!",
            onButtonPressed: () {
              Get.back();
            },
          );
        },
      );
    }
  }

  void _onOrderPressed() {
    if (_selectedPackage != null && _selectedIndex != -1) {
      final bottleData = _bottleItems[_selectedIndex]['itemData'];

      print(_bottleItems[_selectedIndex]);
      print(_bottleItems[_selectedIndex]['price']);
      print([DateTime.now()]);
      final Map<String, dynamic> myOrderData = {
        'bottle': _bottleItems[_selectedIndex],
        'quantity': _quantity,
        'price': bottleData['price'],
        'emptyBottlePrice': _hasEmptyBottle ? bottleData['emptyBottlePrice'] : 0,
        'hasEmptyBottle': _hasEmptyBottle,
        'totalPrice': _totalPrice,
      };
      print("Order Data: $myOrderData");
      print(
        "Total Price: ${_bottleItems[_selectedIndex]['price']} (Type: ${_bottleItems[_selectedIndex]['price'].runtimeType})",
      );
      print("Total Days:1");
      print("Selected Dates: ${[DateTime.now()]}");
      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            orderData: myOrderData,
            totalPrice: _totalPrice, // Ensure this is double
            totalDays: 1,
            selectedDates: [DateTime.now()],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomPopup(
            title: "Oops! Bottle Not Selected",
            description:
                "Please select a bottle before moving forward. This ensures you get the best!",
            buttonText: "Got It!",
            onButtonPressed: () {
              Get.back();
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // _isLoading ? const HomePageShimmer() : ServiceNotAvailableScreen();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppbar(
          onProfilePressed: widget.onProfilePressed,
          onNotificationPressed: () {
            Get.toNamed(
              AppRoutes.notification,
            ); // Navigate to notifications page
          },
          onMenuPressed: widget.onMenuPressed,
          hasNotifications: true,
          badgeCount: 0, // Example badge count
          usersData: usersData, // Profile picture URL
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              // Image Carousel
              SizedBox(
                height: screenHeight * 0.20,
                child: const ImageCarouselPage(),
              ),
              const SizedBox(height: 10),
              if (_stores.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _stores.length + 1, // +1 for "All Bottles"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "All Bottles" tile
                        bool isSelected = _selectedMerchantId == null;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMerchantId = null;
                            });
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[50]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.water_drop, color: Colors.blue),
                                SizedBox(height: 4),
                                Text(
                                  'All Bottles',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Vendor tiles
                      final vendor = _stores[index - 1];
                      bool isSelected =
                          _selectedMerchantId == vendor.merchantId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMerchantId = vendor.merchantId;
                          });
                        },
                        onLongPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailScreen(store: vendor),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[50] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vendor.bankName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendor.vendorName ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Show loading or package selector
              _isLoading
                  ? PackageSelectorShimmer()
                  : WaterBottelWidget(
                      bottleItems: _selectedMerchantId == null
                          ? _bottleItems
                          : _bottleItems
                                .where(
                                  (item) =>
                                      item['itemData']['merchantId'] ==
                                      _selectedMerchantId,
                                )
                                .toList(),
                      onSelected: _onPackageSelected,
                    ),

              const SizedBox(height: 16),

              // Order details component
              OrderDetailsComponent(
                key: ValueKey(_selectedPackage),
                selectedPackage: _selectedPackage,
                onOrderUpdated: (quantity, hasEmptyBottles, totalPrice) {
                  if (_totalPrice != totalPrice) {
                    setState(() {
                      _quantity = quantity;
                      _hasEmptyBottle = hasEmptyBottles;
                      _totalPrice = totalPrice;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SubscribeButtonComponent(
                  text: "Order Now",
                  onPressed: _onOrderPressed,
                ),
              ),
              const SizedBox(height: 4),
              // Subscribe button
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SubscribeButtonComponent(
                  text: "Subscribe Now",
                  icon: Icons.check_circle,
                  onPressed: _onSubscribePressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
