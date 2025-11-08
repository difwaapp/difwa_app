import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/stores_models/withdraw_request_model.dart';
import 'package:difwa_app/utils/app__text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestForWithdraw extends StatefulWidget {
  const RequestForWithdraw({super.key});

  @override
  State<RequestForWithdraw> createState() => _RequestForWithdrawState();
}

class _RequestForWithdrawState extends State<RequestForWithdraw> {
  TextEditingController amountController = TextEditingController();
  WalletController? walletController;
  final PaymentHistoryController _paymentHistoryController =
      Get.put(PaymentHistoryController());
  String totalEarnings = "";
  double enteredAmount = 0.0;

  List<WithdrawalRequestModel> withdrawalRequests = []; // Corrected list type

  @override
  void initState() {
    super.initState();
    totalEarnings = Get.arguments.toString();
    fetchWithdrawalRequests(); // Fetch requests on screen load
  }

  Future<void> fetchWithdrawalRequests() async {
    try {
      print("Fetching withdrawal requests...");

      List requests = await _paymentHistoryController.fetchAllRequestForWithdraw();
      print("Fetched requests: $requests"); // Debugging: Show raw data

      setState(() {
        withdrawalRequests = requests.cast<WithdrawalRequestModel>();
      });

      print("Withdrawal requests updated in state: $withdrawalRequests"); // Debugging: Confirm state update
    } catch (e) {
      print("Error fetching withdrawal requests: $e"); // Debugging: Log the error
      Get.snackbar("Error", "Failed to load withdrawal requests.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _withdrawMoney() async {
    double? parsedEarnings = double.tryParse(totalEarnings);

    if (parsedEarnings != null &&
        enteredAmount > 0 &&
        enteredAmount <= parsedEarnings) {
      await _paymentHistoryController.requestForWithdraw(enteredAmount);
      Get.snackbar("Success", "Your withdrawal request has been submitted!",
          snackPosition: SnackPosition.BOTTOM);
      fetchWithdrawalRequests(); // Refresh the list after new request
    } else {
      Get.snackbar("Error", "Invalid withdrawal amount.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
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
          "Withdraw Amount",
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
            const Text("Current Balance",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              "₹ $totalEarnings",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  enteredAmount = double.tryParse(value) ?? 0;
                });
              },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 20, 50, 100]
                  .map((amount) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enteredAmount = amount.toDouble();
                            amountController.text = amount.toString();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        child: Text("+₹${amount.toString()}"),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Transaction History",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "A 1.5% processing fee may apply. Funds typically arrive within 24 hours.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _withdrawMoney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Withdraw",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Withdrawal Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            withdrawalRequests.isEmpty
                ? const Text("No withdrawal requests found.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: withdrawalRequests.length,
                    itemBuilder: (context, index) {
                      final request = withdrawalRequests[index];
                      return Card(
                        color: Colors.black,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("₹${request.amount.toStringAsFixed(2)}",style: AppTextStyle.Text16600.copyWith(color: Colors.white),),
                          subtitle: Text("Status: ${request.paymentStatus}",style: AppTextStyle.Text16600.copyWith(color: Colors.white)),
                          trailing: Text(
                          style: AppTextStyle.Text16600.copyWith(color: Colors.white),
                              request.timestamp.toLocal().toString().substring(0, 16)),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
