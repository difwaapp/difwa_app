class PaymentData {
  final String date;
  double amount;

  PaymentData({required this.date, required this.amount});
   Map<String, dynamic> toJson() {

    return {

      'date': date,

      'amount': amount,

    };

  }
}


