import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/checkout_controller.dart';

class VendorOrderVerification extends StatefulWidget {
  const VendorOrderVerification({Key? key}) : super(key: key);

  @override
  State<VendorOrderVerification> createState() => _VendorOrderVerificationState();
}

class _VendorOrderVerificationState extends State<VendorOrderVerification> {
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final CheckoutController _controller = Get.put(CheckoutController());

  @override
  void dispose() {
    _orderIdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Order Delivery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'Order ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Delivery OTP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_clock),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
                  onPressed: _controller.isLoading.value
                      ? null
                      : () async {
                          final orderId = _orderIdController.text.trim();
                          final otp = _otpController.text.trim();

                          if (orderId.isEmpty || otp.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter both Order ID and OTP',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          bool success = await _controller.verifyDeliveryOtp(orderId, otp);
                          if (success) {
                            _orderIdController.clear();
                            _otpController.clear();
                            Get.defaultDialog(
                              title: "Delivery Confirmed",
                              middleText: "Order has been marked as delivered.",
                              textConfirm: "OK",
                              confirmTextColor: Colors.white,
                              onConfirm: () => Get.back(),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify Delivery'),
                )),
          ],
        ),
      ),
    );
  }
}
