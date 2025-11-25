import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/widgets/custom_button.dart';
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
  final VendorsController _vendorsController = Get.put(VendorsController());

  // Reactive state variables
  final RxString _status = RxString('pending');
  final RxString _remark = RxString('');
  final RxBool _isVerified = RxBool(false);
  final RxBool _isLoading = RxBool(true);
  final RxBool _isSubmitting = RxBool(false);

  @override
  void initState() {
    super.initState();
    _listenForVerification();
  }

  /// Listens to vendor verification status changes in real-time
  Future<void> _listenForVerification() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        _navigateToOnboarding();
        return;
      }
      final merchantId = await _vendorsController.fetchMerchantId();
      print(merchantId);
      if (merchantId == null || merchantId.isEmpty) {
        _isLoading.value = false;
        return;
      }

      // Listen to vendor document changes
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(merchantId)
          .snapshots()
          .listen(
            (snapshot) {
              if (!mounted) return;

              if (snapshot.exists) {
                final data = snapshot.data();

                // Update state with null-safe handling
                _isVerified.value = data?['isVerified'] as bool? ?? false;
                _status.value =
                    (data?['status'] as String?)?.toLowerCase() ?? 'pending';
                _remark.value = data?['rejection_reason'] as String? ?? '';
                _isLoading.value = false;

                // Navigate to vendor dashboard if verified
                if (_isVerified.value) {
                  Get.offAllNamed(AppRoutes.verndorDashbord);
                }
              } else {
                _isLoading.value = false;
              }
            },
            onError: (error) {
              if (!mounted) return;
              _isLoading.value = false;
              _showErrorSnackbar(
                'Error listening to verification status: $error',
              );
            },
          );
    } catch (e) {
      if (!mounted) return;
      _isLoading.value = false;
      _showErrorSnackbar('Error initializing verification listener: $e');
    }
  }

  /// Handles role change from storekeeper to user
  Future<void> _handleRoleChange() async {
    if (_isSubmitting.value) return; // Prevent double submission

    try {
      _isSubmitting.value = true;
      await _vendorsController.changeRoleToUser();

      // Navigate after successful role change
      Get.offAllNamed(AppRoutes.userDashbord);
    } catch (e) {
      _isSubmitting.value = false;
      _showErrorSnackbar('Failed to change role: $e');
    }
  }

  /// Navigates to onboarding screen
  void _navigateToOnboarding() {
    Get.offAllNamed(AppRoutes.useronboarding);
  }

  /// Shows error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Gets display text for verification status
  String _getStatusDisplayText() {
    final status = _status.value;
    if (status.isEmpty || status == 'pending') {
      return 'Pending';
    }
    return status[0].toUpperCase() + status.substring(1);
  }

  /// Gets description text based on status and remark
  String _getDescriptionText() {
    final remark = _remark.value;

    if (remark.isNotEmpty) {
      return '$remark\n\nPlease contact us at +918853389395';
    }

    return 'Your store is currently under review by our team. We will notify you once the verification process is complete.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D3757)),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome illustration
                SvgPicture.asset('assets/onboarding/welcome.svg', height: 250),
                const SizedBox(height: 40),

                // Status title
                Text(
                  'Verification ${_getStatusDisplayText()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3757),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description text
                Text(
                  _getDescriptionText(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Action button based on status
                _buildActionButton(),

                const SizedBox(height: 16),

                // Logout button
                _buildLogoutButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Builds action button based on verification status
  Widget _buildActionButton() {
    if (_status.value == 'rejected') {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting.value ? null : _handleRoleChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D3757),
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Get.snackbar(
            'Status',
            'Verification is ${_getStatusDisplayText()}',
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
          'Check Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds logout button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          _navigateToOnboarding();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
