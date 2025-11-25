import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/features/address/adddress_form_page.dart';

// Extension to capitalize first letter
extension CapExtension on String {
  String get capitalizeFirst =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController addressController = Get.put(AddressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appTheme.whiteColor,
        elevation: 0.5,
        title: Text(
          'Address Book',
          style: TextStyleHelper.instance.title16SemiBold,
        ),
        iconTheme: IconThemeData(color: appTheme.blackColor),
      ),
      body: StreamBuilder<List<Address>>(
        stream: addressController.getAddressesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load addresses: ${snapshot.error}'),
            );
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No addresses found',
                      style: TextStyleHelper.instance.body16Regular,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first delivery address.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isSelected = address.isSelected;
              final locationType = (address.locationType ?? 'home')
                  .toLowerCase();

              // build address string ignoring empty fields
              final addressParts = <String>[
                if (address.floor.isNotEmpty) address.floor,
                if (address.street.isNotEmpty) address.street,
                if (address.city.isNotEmpty) address.city,
                if (address.state.isNotEmpty) address.state,
                if (address.zip.isNotEmpty) address.zip,
                if (address.country.isNotEmpty) address.country,
              ];
              final addressLine = addressParts.join(', ');

              return GestureDetector(
                onTap: () async {
                  final confirm = await _showSelectDialog(context);
                  if (confirm == true) {
                    await addressController.selectAddress(address.docId);
                    Get.snackbar(
                      'Selected',
                      'Delivery address updated',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                onLongPress: () {
                  // copy address to clipboard
                  final fullText =
                      '${address.name}\n$addressLine\nPhone: ${address.phone}';
                  Clipboard.setData(ClipboardData(text: fullText));
                  Get.snackbar('Copied', 'Address copied to clipboard');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? appTheme.primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Top row: icon, name, tag, selected chip
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: locationType == 'home'
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.orange.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              locationType == 'home'
                                  ? Icons.home_filled
                                  : Icons.business_center_rounded,
                              color: locationType == 'home'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.name.isNotEmpty
                                      ? address.name
                                      : 'Unnamed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: appTheme.blackColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.phone.isNotEmpty
                                      ? address.phone
                                      : 'No phone',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // location tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: locationType == 'home'
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              locationType,
                              style: TextStyle(
                                color: locationType == 'home'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: appTheme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: appTheme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Selected',
                                    style: TextStyle(
                                      color: appTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Address line
                      if (addressLine.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                addressLine,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      /// actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              // Edit: open form in edit mode
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddressForm(
                                    address: address,
                                    flag: 'isEdit',
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: appTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: appTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () async {
                              final confirm = await _showDeleteDialog(context);
                              if (confirm == true) {
                                await addressController.deleteAddress(
                                  address.docId,
                                );
                                Get.snackbar(
                                  'Deleted',
                                  'Address removed',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Floating add button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressForm(
                address: Address(
                  docId: "",
                  name: "",
                  phone: "",
                  street: "",
                  city: "",
                  state: "",
                  zip: "",
                  country: "",
                  locationType: "home",
                  floor: "",
                  isSelected: false,
                  isDeleted: false,
                  saveAddress: true,
                  uid: "",
                  latitude: null,
                  longitude: null,
                ),
                flag: '',
              ),
            ),
          );
        },
        backgroundColor: appTheme.primaryColor,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<bool?> _showSelectDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.location_on, color: appTheme.primaryColor, size: 36),
        title: const Text('Select Address?'),
        content: const Text(
          'Are you sure you want to use this address for deliveries?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: appTheme.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('YES', style: TextStyle(color: appTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete, color: Colors.red, size: 36),
        title: const Text('Delete Address?'),
        content: const Text('This action will permanently remove the address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: appTheme.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'DELETE',
              style: TextStyle(color: appTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
