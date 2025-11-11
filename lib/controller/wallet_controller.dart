import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/user_models/wallet_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletController extends GetxController {
  double walletBalance = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  /// Redirects to the payment page if amount is valid
  void redirectToPaymentWebsite(double amount) async {
    if (amount >= 30.0) {
      String url =
          'https://www.difwa.com/payment-page?amount=$amount&uid=$currentUserId&returnUrl=app://payment-result';

      try {
        await launch(url);
      } catch (e) {
        print("Error launching payment page: $e");
      }
    } else {
      print("Minimum amount required is 30.");
    }
  }

  /// Updates the wallet balance in Firestore
  void updateWalletBalance(dynamic addedAmount) async {
    if (addedAmount is int) {
      addedAmount = addedAmount.toDouble();
    }

    walletBalance += addedAmount;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({'walletBalance': walletBalance});
      print("Wallet balance updated successfully.");
    } catch (e) {
      print("Error updating wallet balance: $e");
    }
  }

  /// Saves wallet transaction history
  Future<void> saveWalletHistory(
    double amount,
    String amountStatus,
    String paymentId,
    String paymentStatus,
    String? uuid,
  ) async {
    try {
      await _firestore.collection('wallet_history').add({
        'amount': amount,
        'amountStatus': amountStatus,
        'paymentId': paymentId,
        'paymentStatus': paymentStatus,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': uuid,
      });

      debugPrint("Payment history saved successfully.");
    } catch (e) {
      debugPrint("Error saving payment history: $e");
    }
  }
  Future<List<WalletHistoryModal>> fetchWalletHistory() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('wallet_history')
          .where('uid', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      List<WalletHistoryModal> historyList = querySnapshot.docs.map((doc) {
        return WalletHistoryModal.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      print(historyList);

      return historyList;
    } catch (e) {
      debugPrint("Error fetching wallet history: $e");
      return [];
    }
  }
}
