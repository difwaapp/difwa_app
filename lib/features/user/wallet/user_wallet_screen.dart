import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/models/user_models/wallet_history_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserWalletScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onMenuPressed;

  const UserWalletScreen({
    super.key,
    required this.onProfilePressed,
    required this.onMenuPressed,
  });

  @override
  State<UserWalletScreen> createState() => _UserWalletScreenState();
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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AppUser? appUser = await _fs.fetchAppUser(user.uid);
        if (mounted) {
          setState(() {
            usersData = appUser;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
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
      debugPrint(uri.toString());
      bool paymentSuccess = _checkPaymentStatus(uri.toString());
      if (paymentSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment successful!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        elevation: 0,

        title: Text("My Wallet", style:TextStyleHelper.instance.body14BoldPoppins),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 30),
            _buildRecentTransactionsHeader(),
            const SizedBox(height: 16),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appTheme.primaryColor,
            appTheme.secondyColor,
          ], // Deep Indigo Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: appTheme.secondyColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Balance",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
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
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      double walletBalance = 0.0;
                      if (snapshot.hasData &&
                          snapshot.data!.exists &&
                          snapshot.data!.data() != null &&
                          snapshot.data!['walletBalance'] != null) {
                        walletBalance = (snapshot.data!['walletBalance'] as num)
                            .toDouble();
                      }

                      return Text(
                        "₹${walletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.addbalance_screen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Add Money",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
        const Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.useralltransaction);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "See All",
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return FutureBuilder<List<WalletHistoryModal>>(
      future: fetchWalletHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.history, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No transactions yet",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length > 5 ? 5 : snapshot.data!.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = snapshot.data![index];
            final isCredit = transaction.amountStatus == "Credited";

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCredit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.amountStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(transaction.timestamp),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${isCredit ? "+" : "-"}₹${transaction.amount.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: isCredit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }
    return DateFormat('d MMM, h:mm a').format(date);
  }
}
