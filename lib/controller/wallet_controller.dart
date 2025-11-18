// lib/controller/wallet_controller.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Replace with your backend base URL:
const String BACKEND_BASE =
    "https://us-central1-difwa-7aea2.cloudfunctions.net/api";

class WalletController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current user id
  String? get uid => _auth.currentUser?.uid;

  /// Get fresh Firebase ID token (for authenticating with backend)
  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(); // not forcing refresh
  }

  /// Create Razorpay order via backend
  /// Returns parsed JSON response on success, or throws exception
  Future<Map<String, dynamic>> createOrder({required double amount}) async {
    final idToken = await _getIdToken();
    if (idToken == null) throw Exception("Not authenticated");

    final url = Uri.parse("$BACKEND_BASE/payment/create-order");
    String receipt = "w_${uid?.substring(0,8)}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    print(url);
    print(uid);
    final body = jsonEncode({
      "amount": amount,
      "uid": uid,
      "receipt":receipt,
      "notes": "Wallet Payment",
      "currency": "INR",
    });
    print(body);
    print(idToken);
    final resp = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: body,
    );
    print(jsonDecode(resp.body));

    if (resp.statusCode != 200) {
      String detail = resp.body;
      try {
        final parsed = jsonDecode(resp.body);
        detail = parsed['detail']?.toString() ??parsed['error']?.toString() ??resp.body;
      } catch (e) {
         print(" ${resp.statusCode} $detail $e");
      }
      throw Exception("createOrder failed: ${resp.statusCode} $detail");
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    return parsed;
  }

  /// Confirm payment with backend. Backend will verify signature and credit wallet.
  Future<Map<String, dynamic>> confirmPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    String? maybeUid, // optional
  }) async {
    final url = Uri.parse("$BACKEND_BASE/payment/confirm");
    final payload = {
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_order_id": razorpayOrderId,
      "razorpay_signature": razorpaySignature,
      // optionally uid if you want to pass it (backend will find from rz_orders)
      if (maybeUid != null) "uid": maybeUid,
    };

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      String detail = resp.body;
      try {
        final parsed = jsonDecode(resp.body);
        detail =
            parsed['detail']?.toString() ??
            parsed['message']?.toString() ??
            resp.body;
      } catch (e) {
        print(" ${resp.statusCode} $detail $e");
      }
      throw Exception("confirmPayment failed: ${resp.statusCode} $detail");
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    return parsed;
  }

  /// Optional convenience: fetch current wallet balance from Firestore
  Future<double> fetchWalletBalance() async {
    final uidLocal = uid;
    if (uidLocal == null) return 0.0;
    final doc = await _firestore.collection("users").doc(uidLocal).get();
    if (!doc.exists) return 0.0;
    try {
      final v = doc.data()?['walletBalance'] ?? 0;
      return (v is num) ? v.toDouble() : double.parse("$v");
    } catch (e) {
      return 0.0;
    }
  }
}
