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
    DateTime _parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    DateTime? _parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return OrderModel(
      orderId: map['orderId']?.toString() ?? '',
      userId: map['uid']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userMobile: map['userMobile']?.toString() ?? '',
      vendorId: map['merchantId']?.toString() ?? '',
      vendorName: map['vendorName']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      itemPrice: (map['itemPrice'] is num) ? (map['itemPrice'] as num).toDouble() : 0.0,
      quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 0,
      hasEmptyBottle: map['hasEmptyBottle'] == true,
      orderDate: _parseDate(map['timestamp']),
      selectedDate: _parseDate(map['selectedDate']),
      timeSlot: map['timeSlot']?.toString() ?? '',
      paymentStatus: map['paymentStatus']?.toString() ?? '',
      totalAmount: (map['totalPrice'] is num) ? (map['totalPrice'] as num).toDouble() : 0.0,
      walletUsed: (map['walletUsed'] is num) ? (map['walletUsed'] as num).toDouble() : 0.0,
      orderStatus: map['orderStatus']?.toString() ?? '',
      deliveryOtp: map['deliveryOtp']?.toString() ?? '',
      selectedDates: (map['selectedDates'] is List) 
          ? List<Map<String, dynamic>>.from(map['selectedDates'].map((x) => Map<String, dynamic>.from(x))) 
          : [],
      isSubscription: map['isSubscription'] == true,
      subscriptionFrequency: map['subscriptionFrequency']?.toString(),
      subscriptionStartDate: _parseNullableDate(map['subscriptionStartDate']),
      subscriptionEndDate: _parseNullableDate(map['subscriptionEndDate']),
      subscriptionDays: (map['subscriptionDays'] is num) ? (map['subscriptionDays'] as num).toInt() : null,
      deliveryName: map['deliveryName']?.toString() ?? '',
      deliveryPhone: map['deliveryPhone']?.toString() ?? '',
      deliveryStreet: map['deliveryStreet']?.toString() ?? '',
      deliveryCity: map['deliveryCity']?.toString() ?? '',
      deliveryState: map['deliveryState']?.toString() ?? '',
      deliveryZip: map['deliveryZip']?.toString() ?? '',
      deliveryLatitude: (map['deliveryLatitude'] is num) ? (map['deliveryLatitude'] as num).toDouble() : null,
      deliveryLongitude: (map['deliveryLongitude'] is num) ? (map['deliveryLongitude'] as num).toDouble() : null,
    );
  }
}
