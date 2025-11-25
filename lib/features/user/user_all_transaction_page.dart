import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/user_models/wallet_history_model.dart';
import 'package:flutter/material.dart';

class UserAllTransactionPage extends StatefulWidget {
  const UserAllTransactionPage({super.key});

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment successful!")));
        // walletController?.updateWalletBalance(50.0);
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
          .collection('wallet_history')
          .where('uid', isEqualTo: walletController?.uid)
          .orderBy('timestamp', descending: true)
          .get();
      print("lenght");
      print(walletController?.uid);
      return querySnapshot.docs
          .map(
            (doc) =>
                WalletHistoryModal.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint("Error fetching wallet history: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Transactions',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildTransactionsList()],
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
