import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/user_models/wallet_history_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserWalletScreen extends  StatefulWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onMenuPressed;

  const UserWalletScreen({
    super.key,
    required this.onProfilePressed,
    required this.onMenuPressed,
  });

  @override
  _UserWalletScreenState createState() => _UserWalletScreenState();
}

class _UserWalletScreenState extends State<UserWalletScreen> {
  TextEditingController amountController = TextEditingController();
  WalletController? walletController;
  late StreamSubscription _sub;
  final AppLinks _appLinks = AppLinks();

  AppUser? usersData;
  final FirebaseService _fs = Get.find();
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    walletController = WalletController();
    _initAppLinks();
  }

  void _fetchUserData() async {
    try {
      AppUser? user = await _fs.fetchAppUser(
        FirebaseAuth.instance.currentUser!.uid,
      );

      setState(() {
        usersData = user;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
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
      print(uri);
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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppbar(
          onProfilePressed: widget.onProfilePressed,
          onNotificationPressed: () => Get.toNamed(AppRoutes.notification),
          onMenuPressed: widget.onMenuPressed,
          hasNotifications: true,
          badgeCount: 0,
          usersData: usersData,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildRecentTransactionsHeader(),
            const SizedBox(height: 10),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(walletController?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                );
              }

              double walletBalance = 0.0;
              if (snapshot.hasData &&
                  snapshot.data!.exists &&
                  snapshot.data!.data() != null &&
                  snapshot.data!['walletBalance'] != null) {
                walletBalance =
                    (snapshot.data!['walletBalance'] as num).toDouble();
              }

              return Text(
                "₹ ${walletBalance.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addbalance_screen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2575FC),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Add Balance",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.useralltransaction);
          },
          child: Text("See All", style: TextStyle(color: Colors.blue)),
        ),
      ],
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
