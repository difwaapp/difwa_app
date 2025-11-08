import 'package:difwa_app/config/app_color.dart';
import 'package:difwa_app/controller/address_controller.dart';
import 'package:difwa_app/models/address_model.dart';
import 'package:difwa_app/screens/auth/adddress_form_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Extension to capitalize first letter
extension CapExtension on String {
  String get capitalizeFirst =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class SavveAddressPage extends StatelessWidget {
  const SavveAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController addressController = Get.put(AddressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Address Book',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: GetBuilder<AddressController>(
        init: addressController,
        builder: (_) {
          return StreamBuilder<List<Address>>(
            stream: addressController.getAddresses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Failed to load addresses'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No addresses found.'));
              }

              final addresses = snapshot.data!;

              return ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  bool isSelected = address.isSelected;
                  String locationType = address.locationType.toLowerCase();

                  return GestureDetector(
                      onTap: () async {
                        bool? confirmSelection =
                            await _showSelectDialog(context);
                        if (confirmSelection == true) {
                          addressController.selectAddress(address.docId);
                        }
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Row: Icon, Name, Tag
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: locationType == 'home'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    locationType == 'home'
                                        ? Icons.home_filled
                                        : Icons.business_center_rounded,
                                    color: locationType == 'home'
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 26,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    address.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: locationType == 'home'
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    locationType.capitalize!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: locationType == 'home'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            /// Address Details
                            if (address.saveAddress)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 18, color: Colors.grey.shade700),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${address.floor}, ${address.street}, ${address.city}, ${address.country}',
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: 8),

                            /// ZIP
                            Row(
                              children: [
                                Icon(Icons.local_post_office_outlined,
                                    size: 18, color: Colors.grey.shade700),
                                SizedBox(width: 8),
                                Text(
                                  'ZIP: ${address.zip}',
                                  style: TextStyle(
                                      fontSize: 13.5, color: Colors.black87),
                                ),
                              ],
                            ),

                            /// Phone
                            if (address.phone.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined,
                                      size: 18, color: Colors.grey.shade700),
                                  SizedBox(width: 8),
                                  Text(
                                    'Phone: ${address.phone}',
                                    style: TextStyle(
                                        fontSize: 13.5, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],

                            SizedBox(height: 12),

                            /// Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.edit_outlined,
                                        color: AppColors.buttonbgColor,
                                        size: 26),
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () async {
                                    bool? confirmDelete =
                                        await _showDeleteDialog(context);
                                    if (confirmDelete == true) {
                                      await addressController
                                          .deleteAddress(address.docId);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete_outline,
                                        color: Colors.red, size: 26),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.buttonbgColor,
              shape: BoxShape.circle,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressForm(
                    address: Address(
                        docId: "",
                        name: "",
                        street: "",
                        city: "",
                        state: "",
                        zip: "",
                        isDeleted: false,
                        isSelected: false,
                        country: "",
                        phone: "",
                        saveAddress: false,
                        userId: "",
                        floor: "",
                        locationType: ''),
                    flag: "",
                  ),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.add,
              color: AppColors.mywhite,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showSelectDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        icon: Icon(Icons.location_on, color: Colors.blue, size: 40),
        title: Text(
          'Select Address?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text(
          'Are you sure you want to select this address?',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('GO BACK',
                    style: TextStyle(color: AppColors.iconbgEnd)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    Text('YES', style: TextStyle(color: AppColors.iconbgEnd)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        icon: Icon(Icons.delete, color: Colors.red, size: 40),
        title: Text(
          'Delete Address?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('GO BACK',
                    style: TextStyle(color: AppColors.iconbgEnd)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    Text('YES', style: TextStyle(color: AppColors.iconbgEnd)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
