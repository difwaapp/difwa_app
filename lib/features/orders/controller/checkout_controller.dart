import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'package:difwa_app/services/wallet_service.dart';
import 'package:difwa_app/features/orders/views/order_success_dialog.dart';
import 'package:difwa_app/features/user/orders/orders_screen.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';
import 'package:difwa_app/models/Address.dart';

class CheckoutController extends GetxController {
  final OrderService _orderService = OrderService();
  final WalletService _walletService = WalletService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;

  String generateOtp() {
    var rng = Random();
    return (1000 + rng.nextInt(9000)).toString();
  }

  Future<bool> placeOrder(OrderModel order) async {
    isLoading.value = true;
    try {
      // Deduct wallet amount if used
      if (order.walletUsed > 0) {
        await _walletService.debitWallet(
          uid: order.userId,
          amount: order.walletUsed,
          reason: 'Order Payment: ${order.itemName}',
          orderId: order.orderId,
        );
      }

      await _orderService.createOrder(order);
      
      // Order placed successfully
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    isLoading.value = true;
    try {
      await _orderService.updateOrderStatus(orderId, status);
      Get.snackbar(
        'Success',
        'Order status updated to $status',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyDeliveryOtp(String orderId, String enteredOtp) async {
    isLoading.value = true;
    try {
      bool isValid = await _orderService.verifyOtp(orderId, enteredOtp);
      if (isValid) {
        await updateOrderStatus(orderId, 'delivered');
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Invalid OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Verification failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  final RxDouble walletBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletBalance();
  }

  Future<void> fetchWalletBalance() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          walletBalance.value = (userDoc['walletBalance'] is int)
              ? (userDoc['walletBalance'] as int).toDouble()
              : (userDoc['walletBalance'] ?? 0.0);
        }
      } catch (e) {
        print("Error fetching wallet balance: $e");
      }
    }
  }

  Future<void> processPayment(
      Address address,
      Map<String, dynamic> orderData,
      double totalPrice,
      int totalDays,
      double vacantBottlePrice,
      List<DateTime> selectedDates,
      BuildContext context) async {
    
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    // Fetch user details if needed, or pass them
    // For now assuming we have user details from auth or passed data
    // In a real app, you might want to fetch the user profile here or ensure it's loaded

    // Calculate total amount
    double totalAmount = totalPrice * totalDays + vacantBottlePrice;

    // Check wallet balance
    if (walletBalance.value < totalAmount) {
       showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Oops! Insufficient Balance"),
              content: const Text("Please add funds to your wallet"),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Got It!"),
                )
              ],
            );
          });
      return;
    }

    // Create OrderModel
    // Note: This logic assumes a single order for simplicity, 
    // but handles "subscription" if totalDays > 1 or multiple dates are selected.
    // You might want to refine this based on specific subscription requirements.
    
    bool isSubscription = totalDays > 1;
    
    try {
      // Fetch user data to get name/mobile if not available
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName = userDoc['name'] ?? '';
      String userMobile = userDoc['number'] ?? '';

      // Generate selectedDates list
      List<Map<String, dynamic>> selectedDatesList = [];
      if (selectedDates.isNotEmpty) {
        for (var date in selectedDates) {
          selectedDatesList.add({
            'date': date.toIso8601String(),
            'status': 'pending',
            'dailyOrderId': const Uuid().v4(),
            'statusHistory': {
              'status': 'pending',
              'timestamp': DateTime.now(),
            }
          });
        }
      } else {
        // If no specific dates selected (e.g. single order today), add today
        selectedDatesList.add({
          'date': DateTime.now().toIso8601String(),
          'status': 'pending',
          'dailyOrderId': const Uuid().v4(),
          'statusHistory': {
            'status': 'pending',
            'timestamp': DateTime.now(),
          }
        });
      }

      final order = OrderModel(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
        userId: user.uid,
        userName: userName,
        userMobile: userMobile,
        vendorId: orderData['bottle']['merchantId'] ?? '',
        vendorName: orderData['bottle']['vendorName'] ?? '', // Ensure this is passed or fetched
        itemName: orderData['bottle']['name'] ?? 'Water Can',
        itemPrice: (orderData['price'] ?? 0).toDouble(),
        quantity: orderData['quantity'] ?? 1,
        hasEmptyBottle: orderData['hasEmptyBottle'] ?? false,
        orderDate: DateTime.now(),
        selectedDate: selectedDates.isNotEmpty ? selectedDates.first : DateTime.now(),
        timeSlot: 'Morning', // Default or pass from UI
        paymentStatus: 'paid',
        totalAmount: totalAmount,
        walletUsed: totalAmount,
        orderStatus: 'pending',
        deliveryOtp: generateOtp(),
        selectedDates: selectedDatesList,
        isSubscription: isSubscription,
        subscriptionDays: totalDays,
        subscriptionStartDate: selectedDates.isNotEmpty ? selectedDates.first : null,
        subscriptionEndDate: selectedDates.isNotEmpty ? selectedDates.last : null,
        deliveryName: address.name,
        deliveryPhone: address.phone,
        deliveryStreet: address.street,
        deliveryCity: address.city,
        deliveryState: address.state,
        deliveryZip: address.zip,
        deliveryLatitude: address.latitude,
        deliveryLongitude: address.longitude,
      );

      final success = await placeOrder(order);
      
      if (success) {
        // Navigate to success or back
        Navigator.pop(context); // Close checkout
        
        await Get.dialog(const OrderSuccessDialog(), barrierDismissible: false);
        
        // Navigation is handled by OrderSuccessDialog
      }

    } catch (e) {
      print("Error processing payment: $e");
      Get.snackbar('Error', 'Failed to process payment: $e');
    }
  }
}
