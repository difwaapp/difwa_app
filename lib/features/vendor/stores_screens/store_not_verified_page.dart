import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreNotVerifiedPage extends StatefulWidget {
  const StoreNotVerifiedPage({super.key});

  @override
  State<StoreNotVerifiedPage> createState() => _StoreNotVerifiedPageState();
}

class _StoreNotVerifiedPageState extends State<StoreNotVerifiedPage> {
  Stream<DocumentSnapshot>? _vendorStream;
  final VendorsController _vendorsController = Get.put(VendorsController());

  @override
  void initState() {
    super.initState();
    _listenForVerification();
  }

  void _listenForVerification() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Get.offAllNamed(AppRoutes.useronboarding);
      return;
    }
    String? merchantId = await _vendorsController.fetchMerchantId();
    print("444444");
    print(merchantId);
    _vendorStream = FirebaseFirestore.instance
        .collection('stores')
        .doc(merchantId)
        .snapshots();

    _vendorStream!.listen((snapshot) {
      if (snapshot.exists) {
        final isVerified = snapshot['isVerified'] ?? false;
        final merchantId = snapshot['merchantId'] ?? false;
        print('FROM HOME');
        print(merchantId);
        if (isVerified) {
          Get.offAllNamed(AppRoutes.verndorDashbord);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://cdn.pixabay.com/photo/2015/06/03/13/13/water-796634_1280.jpg',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome, Vendor!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your store is currently under review.\nOnce verified, you'll be redirected to your dashboard.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF334155),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar("Pending", "Still waiting for verification.");
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: const Text(
                  "Check Again",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
