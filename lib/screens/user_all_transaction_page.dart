import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/user_models/wallet_history_model.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';

class UserAllTransactionPage extends StatefulWidget {
  const UserAllTransactionPage({
    super.key,
  });

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<UserAllTransactionPage> {
  TextEditingController amountController = TextEditingController();
  WalletController? walletController;
  late StreamSubscription _sub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    walletController = WalletController();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      _handleDeepLink(uri);
    });
    Uri? initialLink = await _appLinks.getInitialLink();
    _handleDeepLink(initialLink);
  }

  void _handleDeepLink(Uri? uri) {
    if (uri != null && uri.toString().contains('app://payment-result')) {
      bool paymentSuccess = _checkPaymentStatus(uri.toString());
      if (paymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful!")),
        );
        walletController?.updateWalletBalance(50.0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed. Please try again.")),
        );
      }
    }
  }

  bool _checkPaymentStatus(String link) {
    return link.contains("success");
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<List<WalletHistoryModal>> fetchWalletHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('difwa_wallet_history')
          .where('userId', isEqualTo: walletController?.currentUserIdd)
          .orderBy('timestamp', descending: true)
          .get();
      print("lenght");
      print(walletController?.currentUserIdd);
      return querySnapshot.docs
          .map((doc) =>
              WalletHistoryModal.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching wallet history: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('All Tranactions',
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return FutureBuilder<List<WalletHistoryModal>>(
      future: fetchWalletHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No transactions found."));
        }

        return Column(
          children: snapshot.data!.map((transaction) {
            return _buildTransactionItem(
              icon: transaction.amountStatus == "Credited"
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: transaction.amountStatus == "Credited"
                  ? Colors.green
                  : Colors.red,
              title: transaction.amountStatus,
              date: transaction.timestamp.toString(),
              amount:
                  "${transaction.amountStatus == "Credited" ? "+" : "-"}₹${transaction.amount.toStringAsFixed(2)}",
              amountColor: transaction.amountStatus == "Credited"
                  ? Colors.green
                  : Colors.red,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}
