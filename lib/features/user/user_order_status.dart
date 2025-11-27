import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Order {
  final String id;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final String status;
  final DateTime date;
  final double totalCost;
  final List<Map<String, dynamic>> selectedDates;

  Order({
    required this.id,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.status,
    required this.date,
    required this.totalCost,
    required this.selectedDates,
  });

  factory Order.fromFirestore(firestore.DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: data['orderId'] ?? doc.id,
      itemName: data['itemName'] ?? 'Unknown Item',
      itemPrice: (data['itemPrice'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      status: data['orderStatus'] ?? 'pending',
      date: (data['timestamp'] as firestore.Timestamp?)?.toDate() ?? DateTime.now(),
      totalCost: (data['totalPrice'] ?? 0.0).toDouble(),
      selectedDates: List<Map<String, dynamic>>.from(data['selectedDates'] ?? []),
    );
  }
}

class OrderStatus extends StatelessWidget {
  final String orderId;

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
            .snapshots(),
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
                Expanded(child: _buildStatusList(order)),
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
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #: ${order.id.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.water_drop, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${order.quantity}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${order.totalCost.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList(Order order) {
    if (order.selectedDates.isEmpty) {
      return const Center(child: Text("No tracking details available"));
    }

    return ListView.builder(
      itemCount: order.selectedDates.length,
      itemBuilder: (context, index) {
        final dateData = order.selectedDates[index];
        final dateStr = dateData['date'] as String;
        final status = dateData['status'] as String? ?? 'pending';
        final DateTime date = DateTime.parse(dateStr);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              DateFormat('EEE, MMM d, yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(color: _getStatusColor(status)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTimeline(status),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered'];
    final currentIndex = steps.indexOf(currentStatus.toLowerCase());
    
    // If status is cancelled, show just that
    if (currentStatus.toLowerCase() == 'cancelled') {
       return const Row(
        children: [
          Icon(Icons.cancel, color: Colors.red),
          SizedBox(width: 8),
          Text('Order Cancelled', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 20,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted && index < currentIndex ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatStepName(step),
                    style: TextStyle(
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing matching the line height
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatStepName(String step) {
    return step.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
