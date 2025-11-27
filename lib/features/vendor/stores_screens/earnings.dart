
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/controller/earning_controller.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/models/vendors_models/vendor_payment_model.dart';
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
    VendorModel? storedata = await _VendorsController.fetchStoreData();

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Earnings Dashboard",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Container
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "₹${total ?? 0.0}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.requestforwithdraw,
                            arguments: total,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Request Withdrawal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Earnings Cards (Today, Yesterday, Weekly, Monthly)
              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildEarningsCard(
                      "Today",
                      earnings["today"] ?? 0,
                      Icons.today,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildEarningsCard(
                      "Yesterday",
                      earnings["yesterday"] ?? 0,
                      Icons.history,
                      Colors.purple,
                    ),
                    const SizedBox(width: 12),
                    _buildEarningsCard(
                      "This Month",
                      earnings["monthly"] ?? 0,
                      Icons.calendar_month,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildEarningsCard(
                      "Last Week",
                      earnings["weekly"] ?? 0,
                      Icons.date_range,
                      Colors.teal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Date Range Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDateRange(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedDateRange == null
                                ? "Select Range"
                                : "${DateFormat('MMM d').format(selectedDateRange!.start)} - ${DateFormat('MMM d').format(selectedDateRange!.end)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedDateRange != null) ...[
                const SizedBox(height: 16),
                _buildEarningsCard(
                  "Custom Range",
                  rangeEarnings,
                  Icons.pie_chart,
                  Colors.indigo,
                  width: double.infinity,
                ),
              ],

              const SizedBox(height: 32),

              // Transactions
              Row(
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
                  TextButton(
                    onPressed: _fetchEarnings,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEarningsList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Earnings Card for Today, Yesterday, etc.
  Widget _buildEarningsCard(
    String title,
    int amount,
    IconData icon,
    Color color, {
    double? width,
  }) {
    return Container(
      width: width ?? 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "₹$amount",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Earnings List (Transactions)
  Widget _buildEarningsList() {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "No transactions yet",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        bool isCredit = transaction.amountStatus == 'Credited';
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
                  color:
                      isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
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
                      isCredit ? "Payment Received" : "Withdrawal",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.timestamp != null
                          ? DateFormat(
                            'MMM d, yyyy • hh:mm a',
                          ).format(transaction.timestamp)
                          : 'Unknown Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${isCredit ? '+' : '-'} ₹${transaction.amount}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
