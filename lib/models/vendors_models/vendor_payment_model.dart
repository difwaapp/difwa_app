import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistoryModel {
  final String merchantId;
  final double amount;
  final String amountStatus;
  final String uid;
  final String paymentId;
  final DateTime timestamp;

  PaymentHistoryModel({
    required this.merchantId,
    required this.amount,
    required this.amountStatus,
    required this.uid,
    required this.paymentId,
    required this.timestamp,
  });

  factory PaymentHistoryModel.fromFirestore(Map<String, dynamic> doc) {
    return PaymentHistoryModel(
      merchantId: doc['merchantId'] ?? '',
      amount: doc['amount'] ?? '',
      amountStatus: doc['amountStatus'] ?? '',
      uid: doc['uid'] ?? '',
      paymentId: doc['paymentId'] ?? '',
      timestamp: (doc['timestamp'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'amount': amount,
      'amountStatus': amountStatus,
      'uid': uid,
      'paymentId': paymentId,
      'timestamp': timestamp,
    };
  }
}
