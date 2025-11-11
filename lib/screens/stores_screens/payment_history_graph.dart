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
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentData.isEmpty) {
      return const Center(
        child: Text(
          "No Data Available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return Container();
    // LineChart(
    //   LineChartData(
    //     titlesData: FlTitlesData(
    //       rightTitles: AxisTitles(),
    //       topTitles: AxisTitles(),
    //       bottomTitles: AxisTitles(
    //         sideTitles: SideTitles(
    //           showTitles: true,
    //           getTitlesWidget: (value, _) {
    //             int index = value.toInt();
    //             if (index >= 0 && index < paymentData.length) {
    //               var date = DateTime.parse(paymentData[index].date);
    //               var dayOfWeek = DateFormat('E').format(date);
    //               return Padding(
    //                 padding: const EdgeInsets.only(top: 8),
    //                 child: Text(dayOfWeek, style: const TextStyle(fontSize: 10)),
    //               );
    //             } else {
    //               return const SizedBox.shrink();
    //             }
    //           },
    //           interval: 1,
    //         ),
    //       ),
    //     ),
    //     gridData: FlGridData(show: false),
    //     borderData: FlBorderData(show: false),
    //     lineBarsData: [
    //       LineChartBarData(
    //         spots: paymentData
    //             .asMap()
    //             .map((index, data) => MapEntry(
    //                   index,
    //                   FlSpot(index.toDouble(), data.amount),
    //                 ))
    //             .values
    //             .toList(),
    //         isCurved: true,
    //         color: Colors.blue,
    //         dotData: FlDotData(show: true),
    //         belowBarData:
    //             BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
    //       ),
    //     ],
    //   ),
    // );
  }
}
