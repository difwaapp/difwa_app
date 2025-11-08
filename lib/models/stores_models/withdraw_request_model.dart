import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalRequestModel {
  final String id;
  final String merchantId;
  final double amount;
  final String paymentStatus;
  final DateTime timestamp;
  final String paymentId;

  WithdrawalRequestModel({
    required this.id,
    required this.merchantId,
    required this.amount,
    required this.paymentStatus,
    required this.timestamp,
    required this.paymentId,
  });

  // Factory constructor to create an instance from Firestore document
  factory WithdrawalRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WithdrawalRequestModel(
      id: doc.id,
      merchantId: data['merchantId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      paymentId: data['paymentId'] ?? '',
    );
  }
}
