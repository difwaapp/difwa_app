import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  var items = <QueryDocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      isLoading.value = true;
      FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        items.value = snapshot.docs;
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      // Handle error
    }
  }

  Future<void> deleteItem(String itemId) async {
    await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
  }
}
