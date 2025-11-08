import 'package:difwa_app/utils/app__text_style.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      startDate = null;
      endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Orders',
          style: AppTextStyle.TextBlack24700,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Stack(
            children: [
              // Custom Indicator
              Positioned(
                bottom: 0,
                left: _tabController.index == 0 ? 0 : screenWidth / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: screenWidth / 2,
                  height: 3,
                  color: Colors.black,
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
                  Tab(icon: Icon(Icons.done_all_rounded), text: 'Completed'),
                ],
                onTap: (index) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  onPressed: _showDateRangePicker,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: _clearFilters,
                ),
              ],
            ),
          ),
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Showing results from: ${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrderList(
                    status: 'pending',
                    searchQuery: searchQuery,
                    startDate: startDate,
                    endDate: endDate),
                OrderList(
                    status: 'completed',
                    searchQuery: searchQuery,
                    startDate: startDate,
                    endDate: endDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// dsfdsfsfds
class OrderList extends StatelessWidget {
  final String status;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderList({
    super.key,
    required this.status,
    required this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('difwa-orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
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
              'No $status orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final orders = snapshot.data!.docs.where((doc) {
          final orderData = doc.data() as Map<String, dynamic>;
          final orderId = doc.id.toLowerCase();
          final orderDate = orderData['timestamp']?.toDate() ?? DateTime(2000);
          final selectedDates = orderData['selectedDates'] is List
              ? orderData['selectedDates'] as List<dynamic>
              : [];

          if (searchQuery.isNotEmpty &&
              !orderId.contains(searchQuery.toLowerCase())) {
            return false;
          }

          if (startDate != null &&
              endDate != null &&
              (orderDate.isBefore(startDate!) || orderDate.isAfter(endDate!))) {
            return false;
          }

          return selectedDates.any((selectedDate) {
            if (selectedDate is Map<String, dynamic>) {
              final statusHistory =
                  selectedDate['statusHistory'] as Map<String, dynamic>?;
              return statusHistory != null && statusHistory['status'] == status;
            }
            return false;
          });
        }).toList();

        if (orders.isEmpty) {
          return Center(
            child: Text(
              'No $status orders found.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            final selectedDates = order['selectedDates'] is List
                ? order['selectedDates'] as List<dynamic>
                : [];

            return Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                      color: ThemeConstants.blackColor.withOpacity(0.1),
                      width: 1)),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Text(
                  "Order #ORD$orderId",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\$${order['totalPrice'].toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatDateTime(order['timestamp'].toDate()),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.keyboard_arrow_down),
                children: selectedDates.map<Widget>((selectedDate) {
                  if (selectedDate is Map<String, dynamic>) {
                    final date = selectedDate['date'] ?? '';
                    final statusHistory =
                        selectedDate['statusHistory'] as Map<String, dynamic>?;

                    if (statusHistory == null) {
                      return const ListTile(
                        title: Text('No Status History Available'),
                      );
                    }

                    return ListTile(
                      title: Text(
                          'Date: ${date.isNotEmpty ? formatDateTime(DateTime.parse(date)) : 'N/A'}'),
                      subtitle: Text('Status: ${statusHistory['status']}'),
                    );
                  }
                  return const ListTile(title: Text('Invalid data entry'));
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
  // dfsf

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
