class OrderModal {
  String bulkOrderId;
  String merchantId;
  String paymentId;
  List<SelectedDate> selectedDates;
  int totalDays;
  double totalPrice;
  String userId;

  OrderModal({
    required this.bulkOrderId,
    required this.merchantId,
    required this.paymentId,
    required this.selectedDates,
    required this.totalDays,
    required this.totalPrice,
    required this.userId,
  });

  factory OrderModal.fromMap(Map<String, dynamic> map) {
    return OrderModal(
      bulkOrderId: map['bulkOrderId'],
      merchantId: map['merchantId'],
      paymentId: map['paymentId'],
      selectedDates: List<SelectedDate>.from(map['selectedDates'].map((x) => SelectedDate.fromMap(x))),
      totalDays: map['totalDays'],
      totalPrice: map['totalPrice'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bulkOrderId': bulkOrderId,
      'merchantId': merchantId,
      'paymentId': paymentId,
      'selectedDates': List<dynamic>.from(selectedDates.map((x) => x.toMap())),
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      'userId': userId,
    };
  }
}

class SelectedDate {
  String dailyOrderId;
  String date;
  String status;
  StatusHistory statusHistory;

  SelectedDate({
    required this.dailyOrderId,
    required this.date,
    required this.status,
    required this.statusHistory,
  });

  factory SelectedDate.fromMap(Map<String, dynamic> map) {
    return SelectedDate(
      dailyOrderId: map['dailyOrderId'],
      date: map['date'],
      status: map['status'],
      statusHistory: StatusHistory.fromMap(map['statusHistory']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyOrderId': dailyOrderId,
      'date': date,
      'status': status,
      'statusHistory': statusHistory.toMap(),
    };
  }
}

class StatusHistory {
  DateTime completedTime;
  DateTime preparingTime;
  DateTime shippedTime;
  String cancelledTime;
  String confirmedTime;
  String ongoingTime;
  DateTime pendingTime;
  String status;

  StatusHistory({
    required this.completedTime,
    required this.preparingTime,
    required this.shippedTime,
    required this.cancelledTime,
    required this.confirmedTime,
    required this.ongoingTime,
    required this.pendingTime,
    required this.status,
  });

  factory StatusHistory.fromMap(Map<String, dynamic> map) {
    return StatusHistory(
      completedTime: DateTime.parse(map['CompletedTime']),
      preparingTime: DateTime.parse(map['PreparingTime']),
      shippedTime: DateTime.parse(map['ShippedTime']),
      cancelledTime: map['cancelledTime'],
      confirmedTime: map['confirmedTime'],
      ongoingTime: map['ongoingTime'],
      pendingTime: DateTime.parse(map['pendingTime']),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CompletedTime': completedTime.toIso8601String(),
      'PreparingTime': preparingTime.toIso8601String(),
      'ShippedTime': shippedTime.toIso8601String(),
      'cancelledTime': cancelledTime,
      'confirmedTime': confirmedTime,
      'ongoingTime': ongoingTime,
      'pendingTime': pendingTime.toIso8601String(),
      'status': status,
    };
  }
}
