// lib/screens/add_balance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:difwa_app/controller/wallet_controller.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});
  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  final WalletController _walletCtrl = Get.put(WalletController());
  final TextEditingController amountController = TextEditingController();
  late Razorpay _razorpay;

  bool _loading = false;
  String _status = "";
  double enteredAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double v) {
    final current = double.tryParse(amountController.text) ?? 0.0;
    final next = current + v;
    amountController.text = next.toStringAsFixed(2);
    setState(() {
      enteredAmount = next;
    });
  }

  Future<void> _startPaymentFlow() async {
    // basic validation
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount < 30) {
      _showSnack("Please enter amount >= ₹30");
      return;
    }

    setState(() {
      _loading = true;
      _status = "Creating order...";
    });

    try {
      // 1) create order via backend
      final order = await _walletCtrl.createOrder(amount: amount);
      final orderId = order['order_id'] as String?;
      final amountPaise = order['amountPaise'] as int? ?? ( (amount*100).round() );
      final keyId = order['key_id'] as String?;

      if (orderId == null || keyId == null) throw Exception("Missing order_id or key_id in response.");

      // 2) open razorpay checkout (native)
      final options = {
        'key': keyId,
        'amount': amountPaise, // paise
        'currency': 'INR',
        'name': 'Difwa Wallet',
        'description': 'Add money to wallet',
        'order_id': orderId,
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#111827'}
      };

      setState(() {
        _status = "Opening checkout...";
      });

      _razorpay.open(options);
      // after this, the flow continues in _handlePaymentSuccess/_handlePaymentError
    } catch (e) {
      _showSnack("Error: ${e.toString()}");
      setState(() {
        _loading = false;
        _status = "Error creating order";
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // response contains paymentId, orderId, signature
    setState(() {
      _status = "Payment success - verifying...";
    });

    try {
      final confirm = await _walletCtrl.confirmPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        maybeUid: _walletCtrl.uid,
      );

      // Backend should credit the wallet and write history.
      _showSnack("Payment credited: ${confirm['message'] ?? 'ok'}");
      setState(() {
        _loading = false;
        _status = "Payment credited";
        amountController.clear();
      });
    } catch (err) {
      _showSnack("Confirm failed: ${err.toString()}");
      setState(() {
        _loading = false;
        _status = "Confirm failed";
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnack("Payment failed: ${response.message}");
    setState(() {
      _loading = false;
      _status = "Payment failed";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnack("External wallet selected: ${response.walletName}");
    setState(() {
      _loading = false;
      _status = "External wallet: ${response.walletName}";
    });
  }

  void _showSnack(String msg) {
    final sc = ScaffoldMessenger.of(context);
    sc.hideCurrentSnackBar();
    sc.showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _balanceWidget() {
    return FutureBuilder<double>(
      future: _walletCtrl.fetchWalletBalance(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final bal = snap.data ?? 0.0;
        return Text("₹ ${bal.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Balance', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Current Balance", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _balanceWidget(),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: "₹ ", hintText: "0.00"),
            onChanged: (v) {
              setState(() {
                enteredAmount = double.tryParse(v) ?? 0;
              });
            },
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [10, 20, 50, 100]
                .map((v) => ElevatedButton(
                      onPressed: () => _addQuickAmount(v.toDouble()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      child: Text("+₹$v"),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _startPaymentFlow,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Add Money"),
            ),
          ),
          const SizedBox(height: 16),
          Text("Status: $_status", style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}