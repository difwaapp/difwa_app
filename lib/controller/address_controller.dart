import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Address> addressList = <Address>[].obs;

  Rx<Address?> selectedAddress = Rx<Address?>(null);

  void selectAddress(String docId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }

      CollectionReference addressCollection = FirebaseFirestore.instance
          .collection('difwa-users')
          .doc(user.uid)
          .collection('User-address');

      QuerySnapshot selectedAddressSnapshot = await addressCollection
          .where('isSelected', isEqualTo: true)
          .limit(1)
          .get();

      if (selectedAddressSnapshot.docs.isNotEmpty) {
        DocumentSnapshot selectedAddressDoc =
            selectedAddressSnapshot.docs.first;
        await selectedAddressDoc.reference.update({
          'isSelected': false,
        });
        print("Previously selected address deselected.");
      }

      DocumentReference addressDocRef = addressCollection.doc(docId);
      DocumentSnapshot addressDocSnapshot = await addressDocRef.get();

      if (addressDocSnapshot.exists) {
        await addressDocRef.update({
          'isSelected': true,
        });
        print("Address selection updated successfully!");
        selectedAddress.value =
            Address.fromJson(addressDocSnapshot.data() as Map<String, dynamic>);
        print("printing seelcted address");
        print(selectedAddress);
      } else {
        print("Address not found!");
      }
    } catch (e) {
      print("Error toggling address selection: $e");
    }
  }

  // Function to save address
  Future<bool> saveAddress(Address address) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        address.userId = user.uid;

        DocumentReference docRef = _firestore
            .collection('difwa-users')
            .doc(user.uid)
            .collection('User-address')
            .doc();
        address.docId = docRef.id;
        await docRef.set(address.toJson(), SetOptions(merge: true));

        Get.snackbar('Success', 'Address saved successfully!');
        return true;
      } else {
        Get.snackbar('Error', 'User not logged in.');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save the address: $e');
      return false;
    }
  }

  Stream<List<Address>> getAddresses() {
    final user = _auth.currentUser;

    if (user != null) {
      return _firestore
          .collection('difwa-users')
          .doc(user.uid)
          .collection('User-address')
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .map((querySnapshot) {
        List<Address> addresses = querySnapshot.docs.map((doc) {
          return Address.fromJson(doc.data());
        }).toList();

        // Check if there is exactly one address and make it selected
        if (addresses.length == 1) {
          addresses[0].isSelected = true;
          selectedAddress.value = addresses[0];
          _firestore
              .collection('difwa-users')
              .doc(user.uid)
              .collection('User-address')
              .doc(addresses[0].docId)
              .update({
            'isSelected': true
          }); // Update the Firestore document as well
        }

        // Check if there is an address marked as selected
        selectedAddress.value = addresses.firstWhere(
          (address) => address.isSelected == true,
          orElse: () => Address
              .defaultAddress(), // Return a default Address if no address is selected
        );

        return addresses;
      });
    } else {
      return Stream.value([]);
    }
  }

  // Function to delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('difwa-users')
            .doc(user.uid)
            .collection('User-address')
            .doc(addressId)
            .delete();

        Get.snackbar('Success', 'Address deleted successfully!');
      } else {
        Get.snackbar('Error', 'User not logged in.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete the address: $e');
    }
  }

  // Function to update an address
  Future<void> updateAddress(Address address) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await _firestore
            .collection('difwa-users')
            .doc(user.uid)
            .collection('User-address')
            .doc(address.docId)
            .update(address.toJson());

        Get.snackbar('Success', 'Address updated successfully!');
      } else {
        Get.snackbar('Error', 'User not logged in.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update the address: $e');
    }
  }

  Future<bool> hasAddresses() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('difwa-users')
            .doc(user.uid)
            .collection('User-address')
            .where('isDeleted', isEqualTo: false)
            .get();

        return snapshot.docs.isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking for addresses: $e");
      return false;
    }
  }

  Address? slectedAddress() {
    print("i am from contrller of address");
    // print(selectedAddress.value!.country);
    return selectedAddress.value;
  }

  Stream<Address?> getSelectedAddress() {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in!");
      return Stream.value(null);
    }

    // Reference to the user's address collection
    CollectionReference addressCollection = FirebaseFirestore.instance
        .collection('difwa-users')
        .doc(user.uid)
        .collection('User-address');

    // Real-time listener
    return addressCollection
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      print(
          "Debug: getSelectedAddress snapshot received with ${snapshot.docs.length} docs");
      if (snapshot.docs.isNotEmpty) {
        var addressDocSnapshot = snapshot.docs.first;
        print("Debug: Selected address data: ${addressDocSnapshot.data()}");
        return Address.fromJson(
          addressDocSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        print("Debug: No address selected");
        return null; // No address selected
      }
    });
  }
}
