import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistoryModel {
  final String merchantId;
  final double amount;
  final String amountStatus;
  final String userId;
  final String paymentId;
  final DateTime timestamp;

  PaymentHistoryModel({
    required this.merchantId,
    required this.amount,
    required this.amountStatus,
    required this.userId,
    required this.paymentId,
    required this.timestamp,
  });

  // Create a PaymentHistoryModel from a Firestore document
  factory PaymentHistoryModel.fromFirestore(Map<String, dynamic> doc) {
    return PaymentHistoryModel(
      merchantId: doc['merchantId'] ?? '',
      amount: doc['amount'] ?? '',
      amountStatus: doc['amountStatus'] ?? '',
      userId: doc['userId'] ?? '',
      paymentId: doc['paymentId'] ?? '',
      timestamp: (doc['timestamp'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Convert PaymentHistoryModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'amount': amount,
      'amountStatus': amountStatus,
      'userId': userId,
      'paymentId': paymentId,
      'timestamp': timestamp,
    };
  }
}
