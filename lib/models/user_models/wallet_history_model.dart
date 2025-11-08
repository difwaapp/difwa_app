


import 'package:cloud_firestore/cloud_firestore.dart';

class WalletHistoryModal {
  final double amount;
  final String amountStatus;
  final String paymentId;
  final String paymentStatus;
  final DateTime timestamp;
  final String userId;

  WalletHistoryModal({
    required this.amount,
    required this.amountStatus,
    required this.paymentId,
    required this.paymentStatus,
    required this.timestamp,
    required this.userId,
  });

  // Factory method to create an instance from Firestore data
  factory WalletHistoryModal.fromMap(Map<String, dynamic> data) {
    return WalletHistoryModal(
      amount: (data['amount'] as num).toDouble(),
      amountStatus: data['amountStatus'] ?? '',
      paymentId: data['paymentId'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }
}


