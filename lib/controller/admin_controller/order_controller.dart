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
        .collection('difwa-orders')
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

    for (var doc in userDoc.docs) {
      var selectedDates = doc['selectedDates'];

      if (selectedDates != null) {
        for (var selectedDate in selectedDates) {
          var statusHistory = selectedDate['statusHistory'];
          if (statusHistory != null) {
            String orderDate = selectedDate['date'].toString().split("T")[0];

            overallTotalOrders++;

            if (statusHistory['status'] == 'pending') {
              overallPendingOrders++;
            }
            if (statusHistory['status'] == 'Completed') {
              overallCompletedOrders++;
            }
            if (statusHistory['status'] == 'Preparing') {}
            if (statusHistory['status'] == 'Shipped') {}
            if (orderDate == todayStr) {
              todayTotalOrders++;

              if (statusHistory['status'] != 'Completed') {
                todayPendingOrders++;
              }
              if (statusHistory['status'] == 'Completed') {
                todayTotalCompletedOrder++;
              }
              if (statusHistory['status'] == 'Preparing') {
                todayPreparingOrders++;
                // Handle cancelled orders if needed
              }
              if (statusHistory['status'] == 'Shipped') {
                todayShippedOrders++;
              }
            }
          }
        }
      }
    }

    print("Total Today's Orders: $todayTotalOrders");
    print("Total Today's Pending Orders: $todayPendingOrders");
    print("Total Today's Completed Orders: $todayTotalCompletedOrder");
    print("Total Today's Preparing Orders: $todayPreparingOrders");
    print("Total Today's Shipped Orders: $todayShippedOrders");
    print("Total Overall Orders: $overallTotalOrders");
    print("Total Overall Pending Orders: $overallPendingOrders");
    print("Total Overall Completed Orders: $overallCompletedOrders");

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
        .collection('difwa-orders')
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
                "    statusHistory is neither a List nor a Map. It is of type: ${statusHistory.runtimeType}");
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
            "  Not all statusHistory entries are completed. Skipping this order.");
      }
    }

    // Debug: Print the number of completed orders found
    print("Found ${completedOrders.length} completed orders.");
    print(
        "Completed Orders new: ${completedOrders.map((doc) => doc.data()).toList()}");
    return completedOrders;
  }
}
