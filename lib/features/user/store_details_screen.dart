import 'package:flutter/material.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart'; // or vendor model

class StoreDetailScreen extends StatelessWidget {
  final VendorModel store;

  const StoreDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(store.vendorName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vendor Name: ${store.vendorName}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Status: ${store.isActive ? 'Active' : 'Inactive'}"),
            const SizedBox(height: 10),
            Text("Contact: ${store.phoneNumber ?? 'N/A'}"),
            const SizedBox(height: 10),
            Text("Location: ${store.bankName ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }
}
