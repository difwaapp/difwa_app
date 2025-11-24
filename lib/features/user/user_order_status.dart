import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:difwa_app/features/user/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatus extends StatelessWidget {
  final String orderId; // Change to accept orderId

  const OrderStatus({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<firestore.DocumentSnapshot>(
        stream: firestore.FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(), // Listen for document changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final order = Order.fromFirestore(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(order),
                const SizedBox(height: 20),
                const Text(
                  'Track Order',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildDurationsList(order)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Container(
      
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order#: ${order.id}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        item.imageUrl,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.name} - Rs.${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
              'Status: ${order.orderDelivered ? 'Success Delivered' : 'Not Still Delivered'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDurationsList(Order order) {
    Map<String, List<Map<String, dynamic>>> groupedDurations = {};

    for (var duration in order.durations) {
      String date = duration['date'] ?? 'Unknown Date';
      if (!groupedDurations.containsKey(date)) {
        groupedDurations[date] = [];
      }
      groupedDurations[date]!.add(duration);
    }

    return ListView(
      children: groupedDurations.entries.map((entry) {
        return ExpansionTile(
          title: Text(entry.key),
          children: entry.value.map((duration) {
            String message = _getStatusMessage(duration);

            bool orderDelivered = duration['orderdelivered'] ?? false;
            bool orderConfirmed = true;
            bool orderPreparing = duration['orderpreparing'] ?? false;
            bool outForDelivery = duration['outfordelivery'] ?? false;
            bool orderCancelled = duration['ordercanceled'] ?? false;

            Color statusColor = orderDelivered ? Colors.green : Colors.red;

            return ListTile(
              title: Text(
                message,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
              subtitle: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.check,
                                color: orderConfirmed
                                    ? Colors.green
                                    // ignore: dead_code
                                    : Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                // ignore: dead_code
                                'Confirmed: ${orderConfirmed ? 'Yes at ${order.orderConfirmedTimeAndDate}' : 'No'}',
                                style: TextStyle(
                                    color: orderConfirmed
                                        ? Colors.green
                                        // ignore: dead_code
                                        : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Row(
                        children: [
                          Icon(Icons.settings,
                              color:
                                  orderPreparing ? Colors.green : Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Preparing: ${orderPreparing ? 'Yes at ${preparingTime(duration)}' : 'No'}',
                              style: TextStyle(
                                  color: orderPreparing
                                      ? Colors.green
                                      : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.delivery_dining,
                                color: outForDelivery
                                    ? Colors.green
                                    : Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Out for Delivery: ${outForDelivery ? 'Yes at ${outForDeliveryTime(duration)}' : 'No'}',
                                style: TextStyle(
                                    color: outForDelivery
                                        ? Colors.green
                                        : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.cancel,
                                color:
                                    orderCancelled ? Colors.red : Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Cancelled: ${orderCancelled ? 'Yes at ${cancellationTime(duration)}' : 'No'}',
                                style: TextStyle(
                                    color: orderCancelled
                                        ? Colors.red
                                        : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  String _getStatusMessage(Map<String, dynamic> duration) {
    DateTime dateTime;

    if (duration['date'] is firestore.Timestamp) {
      dateTime = (duration['date'] as firestore.Timestamp).toDate();
    } else if (duration['date'] is String) {
      dateTime = DateTime.parse(duration['date']);
    } else {
      dateTime = DateTime.now();
    }

    String formattedDate = DateFormat('hh:mm a').format(dateTime);

    return 'Order status updated on $formattedDate';
  }

///////////////////
  String preparingTime(Map<String, dynamic> duration) {
    DateTime dateTime;

    if (duration['preparingTime'] is firestore.Timestamp) {
      dateTime = (duration['preparingTime'] as firestore.Timestamp).toDate();
    } else if (duration['preparingTime'] is String) {
      dateTime = DateTime.parse(duration['preparingTime']);
    } else {
      dateTime = DateTime.now();
    }

    String formattedDate = DateFormat('hh:mm a').format(dateTime);

    return 'Order status updated on $formattedDate';
  }

/////////////////////
  String outForDeliveryTime(Map<String, dynamic> duration) {
    DateTime dateTime;

    if (duration['outForDeliveryTime'] is firestore.Timestamp) {
      dateTime =
          (duration['outForDeliveryTime'] as firestore.Timestamp).toDate();
    } else if (duration['outForDeliveryTime'] is String) {
      dateTime = DateTime.parse(duration['outForDeliveryTime']);
    } else {
      dateTime = DateTime.now();
    }

    String formattedDate = DateFormat('hh:mm a').format(dateTime);

    return 'Order status updated on $formattedDate';
  }

  String cancellationTime(Map<String, dynamic> duration) {
    DateTime dateTime;

    if (duration['cancellationTime'] is firestore.Timestamp) {
      dateTime = (duration['cancellationTime'] as firestore.Timestamp).toDate();
    } else if (duration['cancellationTime'] is String) {
      dateTime = DateTime.parse(duration['cancellationTime']);
    } else {
      dateTime = DateTime.now();
    }

    String formattedDate = DateFormat('hh:mm a').format(dateTime);

    return 'Order status updated on $formattedDate';
  }
}
