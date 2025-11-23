import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/features/user/congratulations_page.dart';
import 'package:difwa_app/utils/generators.dart';
import 'package:difwa_app/widgets/CustomPopup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CheckoutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentUserId = '';
  String? merchantId;
  RxDouble walletBalance = 0.0.obs;

  Future<void> fetchWalletBalance() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUserId).get();
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

  Future<Map<String, String>> getNextOrderIds() async {
    try {
      int currentYear = DateTime.now().year;

      DocumentSnapshot bulkOrderDoc = await _firestore
          .collection('order-counters')
          .doc('lastBulkOrderId')
          .get();
      DocumentSnapshot dailyOrderDoc = await _firestore
          .collection('order-counters')
          .doc('lastDailyOrderId')
          .get();

      int newBulkOrderNumber = 1;
      int newDailyOrderNumber = 1;

      if (bulkOrderDoc.exists) {
        newBulkOrderNumber = (bulkOrderDoc['id'] as int) + 1;
      }

      if (dailyOrderDoc.exists) {
        newDailyOrderNumber = (dailyOrderDoc['id'] as int) + 1;
      }

      String formattedBulkOrderId =
          'DIF$currentYear${newBulkOrderNumber.toString().padLeft(6, '0')}';
      String formattedDailyOrderId =
          'DIF$currentYear${newDailyOrderNumber.toString().padLeft(6, '0')}';

      await _firestore
          .collection('order-counters')
          .doc('lastBulkOrderId')
          .set({'id': newBulkOrderNumber});
      await _firestore
          .collection('order-counters')
          .doc('lastDailyOrderId')
          .set({'id': newDailyOrderNumber});

      return {
        'bulkOrderId': formattedBulkOrderId,
        'dailyOrderId': formattedDailyOrderId
      };
    } catch (e) {
      print("Error fetching or updating order IDs: $e");
      rethrow;
    }
  }

  String generatePaymentId() {
    var uuid = Uuid();
    return 'PAY-${uuid.v4()}';
  }

  Future<void> processPayment(
      Address? address,
      Map<String, dynamic> orderData,
      double totalPrice,
      int totalDays,
      double vacantBottlePrice,
      List<DateTime> selectedDates,
      BuildContext context) async {
    double totalAmount = totalPrice * totalDays + vacantBottlePrice;

    print("dfddfsfdf $orderData");

    if (walletBalance.value >= totalAmount) {
      double newBalance = walletBalance.value - totalAmount;

      try {
        Get.dialog(
        Center(
              child: CircularProgressIndicator(
            backgroundColor: appTheme.primaryColor,
          )),
          barrierDismissible: false, // Prevent user from closing it
        );
        Map<String, String> orderIds = await getNextOrderIds();
        String newBulkOrderId = orderIds['bulkOrderId']!;
        String newDailyOrderId = orderIds['dailyOrderId']!;

        List<Map<String, dynamic>> selectedDatesWithHistory = [];
        for (int i = 0; i < selectedDates.length; i++) {
          String formattedDailyOrderId =
              'DIF${DateTime.now().year}${(int.parse(newDailyOrderId.split(DateTime.now().year.toString())[1]) + i).toString().padLeft(6, '0')}';
          selectedDatesWithHistory.add({
            'date': selectedDates[i].toIso8601String(),
            'dailyOrderId': formattedDailyOrderId,
            'statusHistory': {
              'status': 'pending',
              'pendingTime': Timestamp.now(),
              'ongoingTime': "",
              'confirmedTime': "",
              'cancelledTime': "",
            },
          });
        }

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .update({'walletBalance': newBalance});
        await _firestore.collection('orders').doc(newBulkOrderId).set({
          'bulkOrderId': newBulkOrderId,
          'paymentId': Generators.generatePaymentId(),
          'uid': currentUserId,
          'totalPrice': totalAmount,
          'totalDays': totalDays,
          'selectedDates': selectedDatesWithHistory,
          'orderData': orderData,
          'address': address,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
          'merchantId': orderData['bottle']['merchantId'],
        });
        Get.back();
        Get.to(() => CongratulationsPage());
        await _firestore
            .collection('order-counters')
            .doc('lastDailyOrderId')
            .update({
          'id': int.parse(
                  newDailyOrderId.split(DateTime.now().year.toString())[1]) +
              totalDays -
              1,
        });
      } catch (e) {
        print(e);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomPopup(
                title: "Oops! Something went wrong!",
                description: "Error processing payment: $e",
                buttonText: "Got It!",
                onButtonPressed: () {
                  Get.back();
                },
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomPopup(
              title: "Oops! Insufficient Balance",
              description: "Please add funds to your wallet",
              buttonText: "Got It!",
              onButtonPressed: () {
                Get.back();
              },
            );
          });
    }
  }
}
