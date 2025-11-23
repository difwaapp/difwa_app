
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/earning_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/models/stores_models/vendor_payment_model.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/custom_button.dart';

class EarningsDashboard extends StatefulWidget {
  const EarningsDashboard({super.key});

  @override
  _EarningsDashboardState createState() => _EarningsDashboardState();
}

class _EarningsDashboardState extends State<EarningsDashboard> {
  final EarningController _earningController = Get.put(EarningController());
  final PaymentHistoryController _paymentHistoryController =
      Get.put(PaymentHistoryController());
  final VendorsController _VendorsController = Get.put(VendorsController());

  Map<String, int> earnings = {
    "today": 0,
    "yesterday": 0,
    "weekly": 0,
    "monthly": 0,
    "total": 0,
  };

  List<PaymentHistoryModel> transactions = [];
  DateTimeRange? selectedDateRange;
  double? total;
  int rangeEarnings = 0;
  String? merchantId;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
    _fetchEarnings2();
    _fetchStoreData();
  }

  // Fetch Earnings (Today, Yesterday, Weekly, Monthly, Total)

  void _fetchEarnings() async {
    var fetchedEarnings = await _earningController.fetchEarnings();
    setState(() {
      earnings = fetchedEarnings;
    });
    await _paymentHistoryController.fetchPaymentHistoryByMerchantId();
  }

  void _fetchStoreData() async {
    VendorModal? storedata = await _VendorsController.fetchStoreData();

    print("storedata234");
    print("Store Data11: ${storedata?.earnings}");
    setState(() {
      total = storedata?.earnings;
    });
  }

  // Fetch Payment History for the merchantId
  void _fetchEarnings2() async {
    var fetchedPaymentHistory =
        await _paymentHistoryController.fetchPaymentHistoryByMerchantId();
    setState(() {
      transactions = fetchedPaymentHistory;
    });
  }

  // Fetch Earnings by Date Range
  void _fetchEarningsByRange() async {
    if (selectedDateRange != null) {
      int fetchedRangeEarnings =
          await _earningController.fetchEarningsByDateRange(
        selectedDateRange!.start,
        selectedDateRange!.end,
      );
      setState(() {
        rangeEarnings = fetchedRangeEarnings;
      });
    }
  }

  // Show Date Range Picker
  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      _fetchEarningsByRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 170, 217, 255),
        title: Text(
          "Earnings Dashboard",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Total Balance Container
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
                  )
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
                  Text(
                    "₹${total ?? 0.0}",
                    style: TextStyle(color: Colors.black, fontSize: 66),
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
                        Get.toNamed(AppRoutes.requestforwithdraw,
                            arguments:total);
                      },
                      child: const Text(
                        "Withdraw",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Earnings Cards (Today, Yesterday, Weekly, Monthly)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildEarningsCard("Today", earnings["today"] ?? 0),
                  _buildEarningsCard("Yesterday", earnings["yesterday"] ?? 0),
                  _buildEarningsCard("This Month", earnings["monthly"] ?? 0),
                  _buildEarningsCard("Last Week", earnings["weekly"] ?? 0),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Date Range Selector
            Text("Select Date Range",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: selectedDateRange == null
                      ? Text("No date range selected",
                          style: TextStyle(color: Colors.grey))
                      : Text(
                          "${DateFormat.yMMMd().format(selectedDateRange!.start)} - ${DateFormat.yMMMd().format(selectedDateRange!.end)}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: () => _selectDateRange(context),
                ),
              ],
            ),
            if (selectedDateRange != null)
              _buildEarningsCard("Custom Range", rangeEarnings),
            SizedBox(height: 16),
            // Transactions
            Text("Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(child: _buildEarningsList()),
            SizedBox(height: 16),
            CustomButton(text: "Refresh", onPressed: _fetchEarnings)
          ],
        ),
      ),
    );
  }

  // Earnings Card for Today, Yesterday, etc.
  Widget _buildEarningsCard(String title, int amount) {
    return Card(
      color: appTheme.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text("₹$amount",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Earnings List (Transactions)
  Widget _buildEarningsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        bool isCredit = transaction.amountStatus == 'Credited';
        return Card(
          color:appTheme.whiteColor,
          child: ListTile(
            title: Text(
                transaction.timestamp != null
                    ? DateFormat.yMMMd().format(transaction.timestamp)
                    : 'Unknown Time',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            trailing: Text(
              "₹${transaction.amount}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit
                    ? Colors.green
                    : Colors.red, // Credit in green, debit in red
              ),
            ),
            leading: Icon(
              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
