import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/features/user/user_order_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  final double price;
  final String imageUrl;

  Item({required this.name, required this.price, required this.imageUrl});

  factory Item.fromFirestore(Map<String, dynamic> data) {
    return Item(
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final List<Item> items;
  final List<Map<String, dynamic>> durations;

  final String status;
  final DateTime date;
  final String imageUrl;
  final bool orderCancelled;
  final bool orderConfirmed;
  final bool orderDelivered;
  final bool orderPreparing;
  final bool outForDelivery;
  final double totalCost;
  final DateTime? orderConfirmedTimeAndDate;

  Order({
    required this.id,
    required this.items,
    required this.status,
    required this.date,
    required this.imageUrl,
    required this.orderCancelled,
    required this.orderConfirmed,
    required this.orderDelivered,
    required this.orderPreparing,
    required this.outForDelivery,
    required this.totalCost,
    required this.durations,
    this.orderConfirmedTimeAndDate,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Item> itemList = (data['items'] as List<dynamic>)
        .map((itemData) => Item.fromFirestore(itemData))
        .toList();

    return Order(
      id: doc.id,
      items: itemList,
      status: data['orderstatus'] ?? '',
      date: (data['orderDate'] as Timestamp).toDate(),
      orderConfirmedTimeAndDate:
          (data['orderConfirmedTimeAndDate'] as Timestamp?)?.toDate(),

      imageUrl: data['imageUrl'] ?? '',
      orderCancelled: data['ordercanceled'] ?? false,
      orderConfirmed: data['orderconfirmed'] ?? false,
      orderDelivered: data['orderdelivered'] ?? false,
      orderPreparing: data['orderpreparing'] ?? false,
      outForDelivery: data['outfordelivery'] ?? false,

      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
      durations: List<Map<String, dynamic>>.from(
        data['durations'] ?? [],
      ), // Add this line to parse durations
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const  OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State< OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('uid', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orderList = snapshot.data!.docs
              .map((doc) => Order.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderStatus(orderId: orderList[index].id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order : #${orderList[index].id}',
                          style: TextStyleHelper.instance.body14BoldPoppins,
                        ),
                        ...orderList[index].items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyleHelper
                                            .instance
                                            .body14BoldPoppins,
                                      ),
                                      Text(
                                        'Rs.${item.price.toStringAsFixed(2)}',
                                        style: TextStyleHelper
                                            .instance
                                            .body14BoldPoppins,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 5),
                        Text(
                          'Status: ${orderList[index].status}',
                          style: TextStyleHelper.instance.body14BoldPoppins,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Date: ${orderList[index].date}',
                          style: TextStyleHelper.instance.body14BoldPoppins,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
