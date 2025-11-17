import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/screens/payment_webview_screen.dart';
import 'package:difwa_app/utils/showAwesomeSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  TextEditingController amountController = TextEditingController();
  WalletController? walletController;
  final WalletController _walletController2 = Get.put(WalletController());
  String? userUid = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    walletController = WalletController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double currentBalance = 2458.65;
  double enteredAmount = 0.0;
  String paymentId = "";

  String selectedPaymentMethod = "Visa ending in 4242";
  final List<Map<String, dynamic>> paymentOptions = [
    {
      "title": "UPI",
      "icon": "upi.svg",
      "methods": ["gpay.png", "ppay.png", "paytm.png"],
    },
    {
      "title": "Cards",
      "icon": "card.svg",
      "methods": ["visa.png", "mastercard.png", "rupay.png"],
    },
    {
      "title": "Netbanking",
      "icon": "netbanking.svg",
      "methods": ["bob.png", "sbi.png", "pnb.png"],
    },
    {
      "title": "Wallet",
      "icon": "paywallet.svg",
      "methods": ["mobikwik.png", "paytm.png", "amazon.png"],
    },
    {
      "title": "Pay Later",
      "icon": "paylater.svg",
      "methods": ["lazypay.png", "icici.png", "simpl.png"],
    },
  ];

  // Function to handle amount button taps
  void _addQuickAmount(double amount) {
    setState(() {
      double newAmount = (double.tryParse(amountController.text) ?? 0) + amount;
      amountController.text = newAmount.toStringAsFixed(2);
      enteredAmount = newAmount;
    });
  }

  // Function to select payment method
  void _selectPaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  void redirectToPaymentWebsite(double amount, String? currentUserId) async {
    if (amount >= 30.0) {
      String url =
          'https://www.difwa.com/payment-page?amount=$amount&uid=$currentUserId&returnUrl=app://payment-result';
      //Open WebView and wait for the result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            initialUrl: url,
            amount: amount,
            uid: currentUserId!,
          ),
        ),
      );
      print("Payment Status from add balance: $result");
      if (result != null && result is Map<String, dynamic>) {
        String status = result['status'] ?? 'No status';
        String paymentId = result['payment_id'] ?? 'No payment_id';
        print("Payment Status from add balance: $status");
        print("Payment ID: $paymentId");
        await _walletController2.saveWalletHistory(
          amount,
          "Credited",
          paymentId,
          status,
          userUid,
        );

        // Now you can use the correct paymentId here
      } else {
        print("No result returned from PaymentWebViewScreen.");
      }

      _addMoneySuccess(result);
    } else {
      showAwesomeSnackBar(context, "Please enter an amount greater than ₹30");
    }
  }

  // Function to handle the "Add Money" button
  void _addMoney() {
    if (enteredAmount <= 0) {
      showAwesomeSnackBar(context, "Enter a valid amount!");

      return;
    }

    var currentUserId = FirebaseAuth.instance.currentUser?.uid;
    redirectToPaymentWebsite(enteredAmount, currentUserId);
  }

  // Function to handle the "Add Money" button
  void _addMoneySuccess(result) {
    if (enteredAmount <= 0) {
      showAwesomeSnackBar(context, "Enter a valid amount!");

      return;
    }
    print("result");
    print(result);
    if (result == null) {
      showAwesomeSnackBar(context, "Payment failed. Please try again.");
      return;
    }
    if (result['status'] == 'success') {
      // Payment was successful
      showAwesomeSnackBar(context, "Payment successful!");
    } else {
      // Payment failed
      showAwesomeSnackBar(context, "Payment failed. Please try again.");
    }
    // Simulate balance update
    setState(() {
      currentBalance += enteredAmount;
      amountController.clear();
      enteredAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Balance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Display
            const Text(
              "Current Balance",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 4),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(walletController?.currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Check if data exists
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text(
                    "₹ 0.0",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  );
                }
                // Extract document data
                var userDoc = snapshot.data!;
                double walletBalance = 0.0;

                if (userDoc.data() != null &&
                    userDoc['walletBalance'] != null) {
                  walletBalance = (userDoc['walletBalance'] as num).toDouble();
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
            const SizedBox(height: 20),

            // Amount Input Field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onChanged: (value) => setState(() {
                enteredAmount = double.tryParse(value) ?? 0;
              }),
              decoration: InputDecoration(
                prefixText: "₹ ",
                hintText: "0.00",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Amount Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 20, 50, 100]
                  .map(
                    (amount) => ElevatedButton(
                      onPressed: () => _addQuickAmount(amount.toDouble()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                      child: Text("+₹${amount.toString()}"),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 10),

            // Fee Notice
            const Text(
              "Click 'Add Money' to proceed to the payment page and complete your transaction.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 20),

            // Add Money Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMoney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Money",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
