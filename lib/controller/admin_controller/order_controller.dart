import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VendorsController _vendorsController = Get.put(VendorsController());
  var verificationId = ''.obs;
  var userRole = ''.obs;

  Future<Map<String, int>> fetchTotalTodayOrders() async {
    String? merchantId = await _vendorsController.fetchMerchantId();

    DateTime today = DateTime.now();
    String todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    QuerySnapshot userDoc = await _firestore
        .collection('orders')
        .where('merchantId', isEqualTo: merchantId)
        .get();

    print(userDoc.docs.length);
    int todayPendingOrders = 0;
    int todayTotalOrders = 0;
    int todayTotalCompletedOrder = 0;
    int todayPreparingOrders = 0;
    int todayShippedOrders = 0;
    int overallTotalOrders = 0;
    int overallPendingOrders = 0;
    int overallCompletedOrders = 0;

    print("DEBUG: Fetching stats for Merchant ID: $merchantId");
    print("DEBUG: Today's Date (Local): $todayStr");

    for (var doc in userDoc.docs) {
      var selectedDates = doc['selectedDates'];
      // print("DEBUG: Processing Order ID: ${doc.id}");

      if (selectedDates != null) {
        for (var selectedDate in selectedDates) {
          var statusHistory = selectedDate['statusHistory'];
          if (statusHistory != null) {
            // Handle different date formats safely
            String rawDate = selectedDate['date'].toString();
            String orderDate;
            try {
               // Try parsing as DateTime first to handle various formats
               DateTime parsedDate = DateTime.parse(rawDate);
               orderDate = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
            } catch (e) {
               // Fallback to simple split if parse fails
               orderDate = rawDate.split("T")[0];
            }
            
            String status = (statusHistory['status'] ?? '').toString().toLowerCase();

            // print("DEBUG:   Date: $orderDate (Raw: $rawDate) | Status: $status");

            overallTotalOrders++;

            if (status == 'pending' || status == 'confirmed') {
              overallPendingOrders++;
            }
            if (status == 'completed' || status == 'delivered') {
              overallCompletedOrders++;
            }
            
            if (orderDate == todayStr) {
              // print("DEBUG:   MATCH TODAY! Incrementing stats.");
              todayTotalOrders++;

              if (status == 'pending' || status == 'confirmed') {
                todayPendingOrders++;
              }
              if (status == 'completed' || status == 'delivered') {
                todayTotalCompletedOrder++;
              }
              if (status == 'preparing') {
                todayPreparingOrders++;
              }
              if (status == 'shipped' || status == 'out_for_delivery') {
                todayShippedOrders++;
              }
            }
          }
        }
      }
    }

    print("DEBUG: Final Stats -> Total: $todayTotalOrders, Pending: $todayPendingOrders, Completed: $todayTotalCompletedOrder, Shipped: $todayShippedOrders");

    return {
      'totalOrders': todayTotalOrders,
      'pendingOrders': todayPendingOrders,
      'completedOrders': todayTotalCompletedOrder,
      'preparingOrders': todayPreparingOrders,
      'shippedOrders': todayShippedOrders,
      'overallTotalOrders': overallTotalOrders,
      'overallPendingOrders': overallPendingOrders,
      'overallCompletedOrders': overallCompletedOrders,
    };
  }

  Future<List<DocumentSnapshot>> fetchOrdersWhereAllCompleted() async {
    String? merchantId = await _vendorsController.fetchMerchantId();

    // Debug: Print the merchantId
    print("Merchant ID: $merchantId");

    QuerySnapshot userDoc = await _firestore
        .collection('orders')
        .where('merchantId', isEqualTo: merchantId)
        .get();

    List<DocumentSnapshot> completedOrders = [];

    // Debug: Print the total number of orders fetched
    print("Fetched ${userDoc.docs.length} orders.");

    for (var doc in userDoc.docs) {
      var selectedDates = doc['selectedDates'];

      // Debug: Print the order ID
      print("Processing Order ID: ${doc.id}");

      bool allCompleted = true;

      // Check every selected date's statusHistory
      if (selectedDates != null) {
        for (var selectedDate in selectedDates) {
          var statusHistory = selectedDate['statusHistory'];

          // Debug: Print the selected date and statusHistory
          print("  Checking selected date: ${selectedDate['date']}");
          print("    statusHistory: $statusHistory");

          // Check if statusHistory is a list
          if (statusHistory is List) {
            print("    statusHistory is a List");
            for (var statusEntry in statusHistory) {
              print("      Checking status entry: $statusEntry");

              if (statusEntry['status'] != 'completed') {
                allCompleted = false;
                print("        Status is not completed. Breaking out of loop.");
                break; // Break out of the loop if any status is not "completed"
              }
            }
          } else if (statusHistory is Map) {
            print("    statusHistory is a Map");

            // Ensure the 'status' key exists and is valid
            if (statusHistory.containsKey('status')) {
              var status = statusHistory['status'];

              // Check if 'status' is a String and if it equals "completed"
              if (status is String && status != 'Completed') {
                allCompleted = false;
                print("      Status is not completed. Breaking out of loop.");
              }
            } else {
              print("    statusHistory does not contain a 'status' key");
              allCompleted = false;
            }
          } else {
            print(
              "    statusHistory is neither a List nor a Map. It is of type: ${statusHistory.runtimeType}",
            );
          }

          // Stop further checks if we already found a non-completed status
          if (!allCompleted) break;
        }
      }

      // Debug: Check if all statusHistory entries are completed
      if (allCompleted) {
        print("  All statusHistory entries are completed. Adding this order.");
        completedOrders.add(doc);
      } else {
        print(
          "  Not all statusHistory entries are completed. Skipping this order.",
        );
      }
    }

    // Debug: Print the number of completed orders found
    print("Found ${completedOrders.length} completed orders.");
    print(
      "Completed Orders new: ${completedOrders.map((doc) => doc.data()).toList()}",
    );
    return completedOrders;
  }
}
