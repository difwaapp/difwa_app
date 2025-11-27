import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/wallet_controller.dart';
import 'package:difwa_app/models/vendors_models/withdraw_request_model.dart';
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

  bool isLoading = false;

  void _withdrawMoney() async {
    double? parsedEarnings = double.tryParse(totalEarnings);

    if (parsedEarnings != null &&
        enteredAmount > 0 &&
        enteredAmount <= parsedEarnings) {
      // Show Confirmation Dialog
      Get.defaultDialog(
        title: "Confirm Withdrawal",
        middleText: "Are you sure you want to withdraw ₹$enteredAmount?",
        textCancel: "Cancel",
        textConfirm: "Confirm",
        confirmTextColor: Colors.white,
        onCancel: () {},
        onConfirm: () async {
          Get.back(); // Close Confirmation Dialog

          setState(() {
            isLoading = true;
          });

          try {
            await _paymentHistoryController.requestForWithdraw(enteredAmount);
            
            Get.snackbar(
              "Success",
              "Your withdrawal request has been submitted!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            fetchWithdrawalRequests(); // Refresh the list after new request
            setState(() {
              amountController.clear();
              enteredAmount = 0.0;
            });
          } catch (e) {
            Get.snackbar(
              "Error",
              "Failed to submit request. Please try again.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } finally {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
      );
    } else {
      Get.snackbar(
        "Error",
        "Invalid withdrawal amount.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Withdraw Amount",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Available Balance",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹$totalEarnings",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Amount Input
                const Text(
                  "Enter Amount",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {
                        enteredAmount = double.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      prefixText: "₹ ",
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Amount Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [100, 500, 1000, 2000].map((amount) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ActionChip(
                              label: Text("₹$amount"),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                              onPressed: () {
                                setState(() {
                                  enteredAmount = amount.toDouble();
                                  amountController.text = amount.toString();
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Withdraw Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _withdrawMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Withdraw Funds",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Funds typically arrive within 24 hours.",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 32),

                // History Section
                const Text(
                  "Withdrawal History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                withdrawalRequests.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No withdrawal history",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: withdrawalRequests.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final request = withdrawalRequests[index];
                        Color statusColor;
                        Color statusBgColor;
                        IconData statusIcon;

                        switch (request.paymentStatus.toLowerCase()) {
                          case 'approved':
                          case 'completed':
                            statusColor = Colors.green;
                            statusBgColor = Colors.green.shade50;
                            statusIcon = Icons.check_circle;
                            break;
                          case 'rejected':
                          case 'failed':
                            statusColor = Colors.red;
                            statusBgColor = Colors.red.shade50;
                            statusIcon = Icons.cancel;
                            break;
                          default:
                            statusColor = Colors.orange;
                            statusBgColor = Colors.orange.shade50;
                            statusIcon = Icons.access_time_filled;
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Withdrawal Request",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      request.timestamp.toLocal().toString().substring(0, 16),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${request.amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request.paymentStatus.capitalizeFirst!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
