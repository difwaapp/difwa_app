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

class WalletScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onMenuPressed;

  const WalletScreen({
    super.key,
    required this.onProfilePressed,
    required this.onMenuPressed,
  });

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 5),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(walletController?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text(
                      "₹ 0.0",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  // Extract document data
                  var userDoc = snapshot.data!;
                  double walletBalance = 0.0;

                  if (userDoc.data() != null &&
                      userDoc['walletBalance'] != null) {
                    walletBalance = (userDoc['walletBalance'] as num)
                        .toDouble();
                  }

                  return Text(
                    "₹ ${walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.addbalance_screen);
                  },
                  child: const Text(
                    "Add Balance",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
