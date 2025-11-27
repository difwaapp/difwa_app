import 'package:difwa_app/controller/admin_controller/payment_history_controller.dart';
import 'package:difwa_app/models/vendors_models/payment_data_modal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PaymentHistoryGraph extends StatefulWidget {
  const PaymentHistoryGraph({super.key});

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<PaymentHistoryGraph> {
  List<PaymentData> paymentData = [];
  bool isLoading = true;

  final PaymentHistoryController paymentHistoryController =
      Get.put(PaymentHistoryController());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await paymentHistoryController.fetchProcessedPaymentHistory();
      if (mounted) {
        setState(() {
          paymentData = data;
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
              Icons.show_chart_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              "No Chart Data Available",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 10.0, bottom: 10.0),
      child: LineChart(
        mainData(),
      ),
    );
  }

  LineChartData mainData() {
    List<FlSpot> spots = [];
    double maxAmount = 0;

    for (int i = 0; i < paymentData.length; i++) {
      final amount = paymentData[i].amount;
      if (amount > maxAmount) maxAmount = amount;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    // Add some padding to the top of the chart
    final maxY = maxAmount * 1.2;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5 == 0 ? 1 : maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5 == 0 ? 1 : maxY / 5,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: (paymentData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF2979FF),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.3),
                const Color(0xFF2979FF).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              return LineTooltipItem(
                '₹${flSpot.y.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF9094A6),
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );
    
    if (value.toInt() >= 0 && value.toInt() < paymentData.length) {
      final dateStr = paymentData[value.toInt()].date;
      try {
        final date = DateTime.parse(dateStr);
        final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(dayName, style: style),
        );
      } catch (e) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text('', style: style),
        );
      }
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: const Text(''),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF9094A6),
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
