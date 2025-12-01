import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String userMobile;
  final String vendorId;
  final String vendorName;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final bool hasEmptyBottle;
  final DateTime orderDate;
  final DateTime selectedDate;
  final String timeSlot;
  final String paymentStatus;
  final double totalAmount;
  final double walletUsed;
  final String orderStatus; // pending, confirmed, dispatched, delivered
  final String deliveryOtp;
  final bool isSubscription;
  final String? subscriptionFrequency;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final int? subscriptionDays;

  // Delivery Address Details
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryStreet;
  final String deliveryCity;
  final String deliveryState;
  final String deliveryZip;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  final List<Map<String, dynamic>> selectedDates;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userMobile,
    required this.vendorId,
    required this.vendorName,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.hasEmptyBottle,
    required this.orderDate,
    required this.selectedDate,
    required this.timeSlot,
    required this.paymentStatus,
    required this.totalAmount,
    required this.walletUsed,
    required this.orderStatus,
    required this.deliveryOtp,
    required this.selectedDates,
    this.isSubscription = false,
    this.subscriptionFrequency,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.subscriptionDays,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryStreet,
    required this.deliveryCity,
    required this.deliveryState,
    required this.deliveryZip,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'uid': userId, // Mapped to uid
      'userName': userName,
      'userMobile': userMobile,
      'merchantId': vendorId, // Mapped to merchantId
      'vendorName': vendorName,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'quantity': quantity,
      'hasEmptyBottle': hasEmptyBottle,
      'timestamp': Timestamp.fromDate(orderDate), // Mapped to timestamp
      'selectedDate': Timestamp.fromDate(selectedDate),
      'timeSlot': timeSlot,
      'paymentStatus': paymentStatus,
      'totalPrice': totalAmount, // Mapped to totalPrice
      'walletUsed': walletUsed,
      'orderStatus': orderStatus,
      'deliveryOtp': deliveryOtp,
      'selectedDates': selectedDates,
      'isSubscription': isSubscription,
      'subscriptionFrequency': subscriptionFrequency,
      'subscriptionStartDate': subscriptionStartDate != null ? Timestamp.fromDate(subscriptionStartDate!) : null,
      'subscriptionEndDate': subscriptionEndDate != null ? Timestamp.fromDate(subscriptionEndDate!) : null,
      'subscriptionDays': subscriptionDays,
      'deliveryName': deliveryName,
      'deliveryPhone': deliveryPhone,
      'deliveryStreet': deliveryStreet,
      'deliveryCity': deliveryCity,
      'deliveryState': deliveryState,
      'deliveryZip': deliveryZip,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      userMobile: map['userMobile'] ?? '',
      vendorId: map['merchantId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      itemName: map['itemName'] ?? '',
      itemPrice: (map['itemPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      hasEmptyBottle: map['hasEmptyBottle'] ?? false,
      orderDate: (map['timestamp'] as Timestamp).toDate(),
      selectedDate: (map['selectedDate'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      totalAmount: (map['totalPrice'] ?? 0.0).toDouble(),
      walletUsed: (map['walletUsed'] ?? 0.0).toDouble(),
      orderStatus: map['orderStatus'] ?? '',
      deliveryOtp: map['deliveryOtp'] ?? '',
      selectedDates: List<Map<String, dynamic>>.from(map['selectedDates'] ?? []),
      isSubscription: map['isSubscription'] ?? false,
      subscriptionFrequency: map['subscriptionFrequency'],
      subscriptionStartDate: map['subscriptionStartDate'] != null ? (map['subscriptionStartDate'] as Timestamp).toDate() : null,
      subscriptionEndDate: map['subscriptionEndDate'] != null ? (map['subscriptionEndDate'] as Timestamp).toDate() : null,
      subscriptionDays: map['subscriptionDays'],
      deliveryName: map['deliveryName'] ?? '',
      deliveryPhone: map['deliveryPhone'] ?? '',
      deliveryStreet: map['deliveryStreet'] ?? '',
      deliveryCity: map['deliveryCity'] ?? '',
      deliveryState: map['deliveryState'] ?? '',
      deliveryZip: map['deliveryZip'] ?? '',
      deliveryLatitude: map['deliveryLatitude'],
      deliveryLongitude: map['deliveryLongitude'],
    );
  }
}
