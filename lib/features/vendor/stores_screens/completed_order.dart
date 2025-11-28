import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderListPage2 extends StatefulWidget {
  final String status;
  final String merchantId;

  const OrderListPage2({
    super.key,
    required this.status,
    required this.merchantId,
  });

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage2> {
  late AppUser userDetails;
  DateTime currentDate = DateTime.now();
  Map<String, AppUser> userCache = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('merchantId', isEqualTo: widget.merchantId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching orders'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No ${widget.status} orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;

            // Check if all statusHistory entries are 'completed' for each selected date
            bool allStatusesCompleted = _checkAllStatusesCompleted(
              order['selectedDates'],
            );

            if (!allStatusesCompleted) {
              return SizedBox.shrink(); // Skip this order if not all statuses are 'completed'
            }

            return Card(
              color: appTheme.whiteColor,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order : #$orderId",
                          style: TextStyleHelper.instance.black14Bold,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E9FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹ ${order['totalPrice'].toString()}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          style: TextStyleHelper.instance.body14BoldPoppins
                              .copyWith(color: appTheme.gray100),
                          '${DateFormat('MMMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(order['timestamp'].millisecondsSinceEpoch).toLocal())} ',
                        ),
                        Text(
                          style: TextStyleHelper.instance.primary18Bold
                              .copyWith(color: appTheme.gray100),
                          DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              order['timestamp'].millisecondsSinceEpoch,
                            ).toLocal(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tilePadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person),
                        title: const Text("Selected Dates"),
                        children: order['selectedDates']
                            .where(
                              (dateData) => dateData['status'] == 'Completed',
                            ) // Filter here
                            .map<Widget>((dateData) {
                              DateTime date = DateTime.parse(dateData['date']);
                              String dateStatus =
                                  dateData['status'] ?? 'pending';
                              bool isCurrentDate = _isSameDay(
                                date,
                                currentDate,
                              );

                              return ListTile(
                                title: Text(
                                  '${DateFormat('MMMM d, yyyy').format(date)} ',
                                  style: TextStyle(
                                    color: isCurrentDate
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                subtitle: Text('Status: $dateStatus'),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to compare dates (ignores time)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper method to check if all statusHistory entries are 'completed'
  bool _checkAllStatusesCompleted(List<dynamic> selectedDates) {
    // Ensure that selectedDates is a list before proceeding
    for (var dateData in selectedDates) {
      // Check if 'statusHistory' is a list for each selectedDate
      if (dateData['statusHistory'] is List) {
        for (var statusHistory in dateData['statusHistory']) {
          if (statusHistory['status'] != 'Completed') {
            return false; // If any status is not 'completed', return false
          }
        }
      } else {
        return false; // If 'statusHistory' is not a list, return false
      }
    }
    return true; // All statuses are 'completed'
  }
}
