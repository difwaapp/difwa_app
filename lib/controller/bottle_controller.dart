import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BottleController extends GetxController {
  var bottleItems = <Map<String, dynamic>>[].obs;

  void fetchBottleItems() {
    FirebaseFirestore.instance
        .collection('difwa-stores')
        .get()
        .then((storeSnapshot) {
      for (var storeDoc in storeSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('difwa-stores')
            .doc(storeDoc.id)
            .collection('difwa-items')
            .snapshots()
            .listen((snapshot) {
          bottleItems.clear();

          for (var doc in snapshot.docs) {
            bottleItems.add({
              'size': doc['size'],
              'price': doc['price'],
              'timestamp': doc['timestamp'],
              'userId': doc['userId'],
              'vacantPrice': doc['vacantPrice'],
              'merchantId': doc['merchantId'],
            });
          }
        });
      }
    }).catchError((error) {
      // Handle any errors (e.g., network issues)
      print("Error fetching bottle items: $error");
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchBottleItems(); // Fetch data when the controller is initialized
  }
}
