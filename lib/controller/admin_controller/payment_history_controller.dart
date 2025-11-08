import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/payment_data_modal.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/models/stores_models/vendor_payment_model.dart';
import 'package:difwa_app/models/stores_models/withdraw_request_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VendorsController _VendorsController = Get.put(VendorsController());

  Future<void> savePaymentHistory(
      double amount,
      String amountStatus,
      String userId,
      String paymentId,
      String paymentStatus,
      String bulkOrderId) async {
    try {
      String? merchantId = await _VendorsController.fetchMerchantId();
      if (merchantId == null) {
        throw Exception("Merchant ID not found");
      }
      await _firestore.collection('difwa-vendor_payment_history').doc().set({
        'merchantId': merchantId,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'amountStatus': amountStatus,
        'userId': userId,
        'paymentId': paymentId,
      });

      debugPrint("Payment history saved successfully.");
    } catch (e) {
      debugPrint("Error saving payment history: $e");
    }
  }

  Future<void> requestForWithdraw(double amount) async {
    try {
      debugPrint("Amountt: $amount");
      String? merchantId = await _VendorsController.fetchMerchantId();
      VendorModal? storedata = await _VendorsController.fetchStoreData();

      debugPrint("storedata234");
      debugPrint("Store Data11: ${storedata?.earnings}");

      if (storedata?.earnings == null) {
        throw Exception("Earnings data is null.");
      }

      debugPrint("Earnings value before parsing: ${storedata?.earnings}");

      double? earnings = storedata?.earnings;

      debugPrint("earnings $earnings");
      // Check if earnings is valid
      if (earnings == null) {
        throw Exception("Invalid earnings value: ${storedata?.earnings}");
      }

      debugPrint("amount");
      debugPrint("earnings");
      // debugPrint(amount);
      // debugPrint(earnings);

      double? remainsAmount = earnings - amount;

      debugPrint("Remaininggg Amount: $remainsAmount");

      if (merchantId == null) {
        throw Exception("Merchant ID not found");
      }

      await _firestore.collection('difwa-payment-approved').doc().set({
        'merchantId': merchantId,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentStatus': "pending",
        'paymentId': "",
      });

      await _VendorsController.updateStoreDetails({"earnings": remainsAmount});

   

      await savePaymentHistory(amount, "completed", "Debited", "paymentId123",
          "success", "bulkOrderId123");

      debugPrint("Payment request successfully.");
      Get.snackbar(
        "Success",
        "Payment request successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    } catch (e) {
      debugPrint("Error saving payment history: $e");
      Get.snackbar(
        "Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    }
  }

///////// fetchAllRequestForWithdraw //////////

Future<List<WithdrawalRequestModel>> fetchAllRequestForWithdraw() async {
  try {
    debugPrint("Starting to fetch withdrawal requests...");
    String? merchantId = await _VendorsController.fetchMerchantId();
    debugPrint("Fetched merchantId: $merchantId"); // Debugging merchantId
    if (merchantId == null) {
      throw Exception("Merchant ID not found");
    }
    QuerySnapshot snapshot = await _firestore
        .collection('difwa-payment-approved')
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('timestamp', descending: true)
        .get();

      debugPrint("Fetched90 ${snapshot.docs.length} documents from Firestore.");

      List<WithdrawalRequestModel> requests = snapshot.docs
          .map((doc) => WithdrawalRequestModel.fromFirestore(doc))
          .toList();

      debugPrint("Mapped withdrawal requests: $requests");

      return requests;
    } catch (e) {
      debugPrint("Error fetching withdrawal requests: $e");
      return [];
    }
  }

  Future<List<PaymentHistoryModel>> fetchPaymentHistoryByMerchantId() async {
    try {
      String? merchantId = await _VendorsController.fetchMerchantId();
      if (merchantId == null) {
        throw Exception("Merchant ID not found");
      }
      debugPrint("Fetching payment history for merchantId: $merchantId");
      QuerySnapshot snapshot = await _firestore
          .collection('difwa-vendor_payment_history')
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('timestamp', descending: true)
          .get();

      debugPrint("Fetched ${snapshot.docs.length} payment history records.");

      List<PaymentHistoryModel> paymentHistory = snapshot.docs.map((doc) {
        debugPrint("Processing document with ID: ${doc.id}");
        return PaymentHistoryModel.fromFirestore(
            doc.data() as Map<String, dynamic>);
      }).toList();
      debugPrint("Payment history processed successfully.");
      return paymentHistory;
    } catch (e) {
      debugPrint("Error fetching payment history by merchantId: $e");
      return [];
    }
  }

Future<List<PaymentData>> fetchProcessedPaymentHistory() async {
  try {
    // Fetch merchant ID
    String? merchantId = await _VendorsController.fetchMerchantId();
    if (merchantId == null) {
      throw Exception("Merchant ID not found");
    }

    debugPrint("Merchant ID: $merchantId");

    // Fetch payment history from Firestore
    QuerySnapshot snapshot = await _firestore
        .collection('difwa-vendor_payment_history')
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('timestamp', descending: true)
        .get();

    debugPrint("Fetched ${snapshot.docs.length} payment history records.");

    List<PaymentData> paymentData = [];

    // Iterate through each document in the snapshot
    for (var doc in snapshot.docs) {
      // Convert timestamp to DateTime
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double amount = doc['amount'];
      String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);

      debugPrint("Processing document: $formattedDate, Amount: $amount");

      // Check if the date already exists in the list
      PaymentData? existingData = paymentData.firstWhere(
        (data) => data.date == formattedDate,
        orElse: () => PaymentData(date: formattedDate, amount: 0.0),
      );

      if (existingData.amount == 0.0) {
        // If no existing data found, add the new entry
        debugPrint("New entry found for date: $formattedDate. Adding amount: $amount");
        paymentData.add(PaymentData(date: formattedDate, amount: amount));
      } else {
        // If existing data found, update the amount
        debugPrint("Existing entry found for date: $formattedDate. Updating amount: ${existingData.amount} + $amount");
        existingData.amount += amount;
      }
    }

    debugPrint("Final processed payment data: ${paymentData.map((data)=>data.toJson()).toList()}");

    return paymentData;
  } catch (e) {
    debugPrint("Error fetching payment history: $e");
    return [];
  }
}



}
