import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeUserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get AddressController instance
  late final AddressController _addressController;
  
  // Observables
  final RxList<VendorModel> allVendors = <VendorModel>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> vendorItems =
      <String, List<Map<String, dynamic>>>{}.obs;

  // Filtered items with vendor info
  final RxList<Map<String, dynamic>> filteredItems =
      <Map<String, dynamic>>[].obs;

  // Size filtering
  final RxList<int> availableSizes = <int>[].obs;
  final RxnInt selectedSize = RxnInt();

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _addressController = Get.find<AddressController>();
    _initData();
    _listenToAddressChanges();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    await fetchAllVendorsWithItems();
    _extractAvailableSizes();
    _filterVendors();
    isLoading.value = false;
  }
  
  /// Listen to address changes from AddressController
  void _listenToAddressChanges() {
    ever(_addressController.selectedAddress, (Address? address) {
      debugPrint('Address changed in HomeUserController: ${address?.street}');
      _filterVendors();
    });
  }

  // 2. Fetch All Vendors and their Items
  Future<void> fetchAllVendorsWithItems() async {
    try {
      final snapshot = await _firestore
          .collection('vendors')
          .where('isActive', isEqualTo: true)
          .get();

      final vendors = <VendorModel>[];
      final itemsMap = <String, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final vendor = VendorModel.fromMap(doc.data());
        vendors.add(vendor);

        // Fetch items for this vendor
        final itemsSnapshot = await doc.reference.collection('items').get();
        final items = itemsSnapshot.docs.map((itemDoc) {
          final data = itemDoc.data();
          data['vendorId'] = vendor.merchantId;
          return data;
        }).toList();

        itemsMap[vendor.merchantId] = items;
      }

      allVendors.assignAll(vendors);
      vendorItems.assignAll(itemsMap);
    } catch (e) {
      debugPrint("Error fetching vendors: $e");
    }
  }

  // 3. Extract Available Sizes from Items
  void _extractAvailableSizes() {
    final Set<int> sizes = {};

    for (var itemsList in vendorItems.values) {
      for (var item in itemsList) {
        final size = item['size'];
        if (size != null) {
          if (size is int) {
            sizes.add(size);
          } else if (size is double) {
            sizes.add(size.toInt());
          } else if (size is String) {
            final parsed = int.tryParse(size);
            if (parsed != null) sizes.add(parsed);
          }
        }
      }
    }

    final sortedSizes = sizes.toList()..sort();
    availableSizes.assignAll(sortedSizes);
  }

  // 4. Filter Items by Distance and Size
  void _filterVendors() {
    final address = _addressController.selectedAddress.value;
    final size = selectedSize.value;

    List<Map<String, dynamic>> items = [];

    // Iterate through all vendors and their items
    for (var vendor in allVendors) {
      // Filter by distance if address is available
      bool withinDistance = true;
      double? distanceInKm;

      if (address != null &&
          address.latitude != null &&
          address.longitude != null) {
        if (vendor.latitude != null && vendor.longitude != null) {
          final distanceInMeters = Geolocator.distanceBetween(
            address.latitude!,
            address.longitude!,
            vendor.latitude!,
            vendor.longitude!,
          );

          distanceInKm = distanceInMeters / 1000; // Convert to km
          withinDistance = distanceInMeters <= 5000; // 5 km
        } else {
          withinDistance = false;
        }
      }

      if (!withinDistance) continue;

      // Get items for this vendor
      final vendorItemsList = vendorItems[vendor.merchantId] ?? [];

      for (var item in vendorItemsList) {
        // Filter by size if selected
        if (size != null) {
          final itemSize = item['size'];
          bool matchesSize = false;

          if (itemSize is int) {
            matchesSize = itemSize == size;
          } else if (itemSize is double) {
            matchesSize = itemSize.toInt() == size;
          } else if (itemSize is String) {
            final parsed = int.tryParse(itemSize);
            matchesSize = parsed == size;
          }

          if (!matchesSize) continue;
        }

        // Add item with vendor info
        items.add({
          ...item,
          'vendor': vendor,
          'vendorName': vendor.vendorName,
          'vendorId': vendor.merchantId,
          'distanceKm': distanceInKm,
        });
      }
    }

    filteredItems.assignAll(items);
    debugPrint('Filtered ${items.length} items for address: ${address?.street}');
  }

  // Public methods
  void updateSelectedSize(int? size) {
    selectedSize.value = size;
    _filterVendors();
  }
}
