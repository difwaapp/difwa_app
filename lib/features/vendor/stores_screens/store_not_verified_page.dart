import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    if (merchantId != null && merchantId.isNotEmpty) {
      _vendorStream = FirebaseFirestore.instance
          .collection('stores')
          .doc(merchantId)
          .snapshots();

      _vendorStream!.listen((snapshot) {
        if (snapshot.exists) {
          final isVerified = snapshot['isVerified'] ?? false;
          if (isVerified) {
            Get.offAllNamed(AppRoutes.verndorDashbord);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/onboarding/welcome.svg', height: 250),
              const SizedBox(height: 40),
              const Text(
                "Verification Pending",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3757),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your store is currently under review by our team. We will notify you once the verification process is complete.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      "Status",
                      "Verification is still in progress.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1D3757),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D3757),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Check Status",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAllNamed(AppRoutes.useronboarding);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
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
