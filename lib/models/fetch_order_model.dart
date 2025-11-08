import 'package:cloud_firestore/cloud_firestore.dart';

class FetchOrderDetailsModel {
  final int totalDays;
  final String merchantId;
  final double totalPrice;
  final List<SelectedDate> selectedDates;
  final String bulkOrderId;
  final OrderData orderData;
  final String userId;
  final Timestamp timestamp;
  final String status;

  FetchOrderDetailsModel({
    required this.totalDays,
    required this.merchantId,
    required this.totalPrice,
    required this.selectedDates,
    required this.bulkOrderId,
    required this.orderData,
    required this.userId,
    required this.timestamp,
    required this.status,
  });

  factory FetchOrderDetailsModel.fromMap(Map<String, dynamic> map) {
    return FetchOrderDetailsModel(
      totalDays: map['totalDays'] ?? 0,
      merchantId: map['merchantId'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      selectedDates: (map['selectedDates'] as List?)?.map((e) => SelectedDate.fromMap(e)).toList() ?? [],
      bulkOrderId: map['bulkOrderId'] ?? '',
      orderData: OrderData.fromMap(map['orderData'] ?? {}),
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      status: map['status'] ?? '',
    );
  }
}

class SelectedDate {
  final DateTime date;
  final StatusHistory statusHistory;
  final String dailyOrderId;

  SelectedDate({
    required this.date,
    required this.statusHistory,
    required this.dailyOrderId,
  });

  factory SelectedDate.fromMap(Map<String, dynamic> map) {
    return SelectedDate(
      date: (map['date'] as Timestamp).toDate(),
      statusHistory: StatusHistory.fromMap(map['statusHistory'] ?? {}),
      dailyOrderId: map['dailyOrderId'] ?? '',
    );
  }
}

class StatusHistory {
  final Timestamp? ongoingTime;
  final Timestamp? cancelledTime;
  final Timestamp? confirmedTime;
  final Timestamp pendingTime;
  final String status;

  StatusHistory({
    this.ongoingTime,
    this.cancelledTime,
    this.confirmedTime,
    required this.pendingTime,
    required this.status,
  });

  factory StatusHistory.fromMap(Map<String, dynamic> map) {
    return StatusHistory(
      ongoingTime: map['ongoingTime'],
      cancelledTime: map['cancelledTime'],
      confirmedTime: map['confirmedTime'],
      pendingTime: map['pendingTime'] ?? Timestamp.now(),
      status: map['status'] ?? '',
    );
  }
}

class OrderData {
  final int quantity;
  final double totalPrice;
  final double price;
  final double vacantPrice;
  final bool hasEmptyBottle;
  final Bottle bottle;

  OrderData({
    required this.quantity,
    required this.totalPrice,
    required this.price,
    required this.vacantPrice,
    required this.hasEmptyBottle,
    required this.bottle,
  });

  factory OrderData.fromMap(Map<String, dynamic> map) {
    return OrderData(
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      vacantPrice: (map['vacantPrice'] ?? 0.0).toDouble(),
      hasEmptyBottle: map['hasEmptyBottle'] ?? false,
      bottle: Bottle.fromMap(map['bottle'] ?? {}),
    );
  }
}

class Bottle {
  final int size;
  final String merchantId;
  final double price;
  final double vacantPrice;
  final String userId;
  final Timestamp timestamp;

  Bottle({
    required this.size,
    required this.merchantId,
    required this.price,
    required this.vacantPrice,
    required this.userId,
    required this.timestamp,
  });

  factory Bottle.fromMap(Map<String, dynamic> map) {
    return Bottle(
      size: map['size'] ?? 0,
      merchantId: map['merchantId'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      vacantPrice: (map['vacantPrice'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
