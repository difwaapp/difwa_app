import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/models/stores_models/payment_data_modal.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({super.key});

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<PaymentData> paymentData = [];
  bool isLoading = true;

  final PaymentHistoryController paymentHistoryController =
      Get.put(PaymentHistoryController());

  @override
  void initState() {
    super.initState();
    paymentHistoryController.fetchProcessedPaymentHistory().then((data) {
      setState(() {
        paymentData = data;
        isLoading = false;
      });
    }).catchError((error) {
      print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    if (paymentData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              "No Chart Data Available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Find max amount for scaling
    double maxAmount = 0;
    for (var data in paymentData) {
      if (data.amount > maxAmount) maxAmount = data.amount;
    }
    if (maxAmount == 0) maxAmount = 1; // Avoid division by zero

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: paymentData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final height = (data.amount / maxAmount) * (constraints.maxHeight - 40);
              
              // Simple date formatting (assuming date string is parseable)
              String label = "";
              try {
                final date = DateTime.parse(data.date);
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                label = days[date.weekday - 1];
              } catch (e) {
                label = "${index + 1}";
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: '₹${data.amount.toStringAsFixed(0)}',
                    child: Container(
                      width: 12, // Slim bars
                      height: height < 4 ? 4 : height, // Min height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
