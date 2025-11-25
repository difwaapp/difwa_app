import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BottleController extends GetxController {
  var bottleItems = <Map<String, dynamic>>[].obs;

  void fetchBottleItems() {
    FirebaseFirestore.instance
        .collection('vendors')
        .get()
        .then((vendorsSnapshot) {
      for (var storeDoc in vendorsSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('vendors')
            .doc(storeDoc.id)
            .collection('items')
            .snapshots()
            .listen((snapshot) {
          bottleItems.clear();

          for (var doc in snapshot.docs) {
            bottleItems.add({
              'size': doc['size'],
              'price': doc['price'],
              'timestamp': doc['timestamp'],
              'uid': doc['uid'],
              'emptyBottlePrice': doc['emptyBottlePrice'],
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
