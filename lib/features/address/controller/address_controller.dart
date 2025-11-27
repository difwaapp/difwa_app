// lib/controllers/address_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Address> addressList = <Address>[].obs;
  final Rxn<Address> selectedAddress = Rxn<Address>();
  Stream<List<Address>>? _addressesStream;
  @override
  void onInit() {
    super.onInit();
    _bindAddressesStream();
  }

  @override
  void onClose() {
    // no manual subscription to cancel, Rx streams auto-managed
    super.onClose();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _userAddressCol {
    final uid = _uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('address');
  }

  /// Bind the address stream to the reactive list and selectedAddress
  void _bindAddressesStream() {
    final uid = _uid;
    if (uid == null) {
      addressList.clear();
      selectedAddress.value = null;
      return;
    }

    _addressesStream = _firestore
        .collection('users')
        .doc(uid)
        .collection('address')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) {
            final map = d.data()..putIfAbsent('docId', () => d.id);
            map['docId'] = map['docId'] ?? d.id;
            return Address.fromMap(map);
          }).toList();
          // If exactly one address exists and none is selected, mark first as selected locally
          final hasSelected = list.any((a) => a.isSelected == true);
          if (!hasSelected && list.length == 1) {
            list[0].isSelected = true;
            _setSingleSelectedOnServer(uid, list[0].docId);
          }

          final s = list.firstWhere(
            (a) => a.isSelected == true,
            orElse: () =>
                list.isNotEmpty ? list.first : Address.defaultAddress(uid),
          );
          selectedAddress.value = list.isNotEmpty ? s : null;

          addressList.assignAll(list);
          return list;
        });
    _addressesStream!.listen(
      (_) {},
      onError: (err) {
        print('[AddressController] addresses stream error: $err');
      },
    );
  }

  Future<void> _setSingleSelectedOnServer(String uid, String docId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('address')
          .doc(docId);
      await docRef.set({'isSelected': true}, SetOptions(merge: true));
    } catch (e) {
      print('[AddressController] _setSingleSelectedOnServer error: $e');
    }
  }

  Stream<List<Address>> getAddressesStream() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('address')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final raw = d.data();
            raw['docId'] = d.id;

            if (raw['createdAt'] is Timestamp) {
              raw['createdAt'] = (raw['createdAt'] as Timestamp).toDate();
            }
            if (raw['updatedAt'] is Timestamp) {
              raw['updatedAt'] = (raw['updatedAt'] as Timestamp).toDate();
            }

            return Address.fromMap(raw);
          }).toList(),
        );
  }

  Stream<Address?> getSelectedAddressStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('address')
        .where('isDeleted', isEqualTo: false)
        .where('isSelected', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final data = snap.docs.first.data();
          data['docId'] = data['docId'] ?? snap.docs.first.id;
          return Address.fromMap(data);
        });
  }
    Stream<Address?> getSelectedAddressByUid(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('address')
        .where('isDeleted', isEqualTo: false)
        .where('isSelected', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final data = snap.docs.first.data();
          data['docId'] = data['docId'] ?? snap.docs.first.id;
          return Address.fromMap(data);
        });
  }


  Future<void> selectAddress(String docId) async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    final addressCol = _firestore
        .collection('users')
        .doc(uid)
        .collection('address');

    try {
      final batch = _firestore.batch();
      final currentSelectedQuery = await addressCol
          .where('isSelected', isEqualTo: true)
          .get();
      for (final d in currentSelectedQuery.docs) {
        if (d.id != docId) {
          batch.update(d.reference, {'isSelected': false});
        }
      }

      final newSelectedRef = addressCol.doc(docId);
      batch.set(newSelectedRef, {'isSelected': true}, SetOptions(merge: true));

      await batch.commit();
      final idx = addressList.indexWhere((a) => a.docId == docId);
      if (idx != -1) {
        for (var i = 0; i < addressList.length; i++) {
          addressList[i].isSelected = i == idx;
        }
        selectedAddress.value = addressList[idx];
      } else {
        _bindAddressesStream();
      }
    } catch (e) {
      print('[AddressController] selectAddress error: $e');
      Get.snackbar('Error', 'Could not select address');
    }
  }

  Future<bool> saveAddress(Address address) async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User not logged in.');
      return false;
    }

    try {
      final col = _firestore.collection('users').doc(uid).collection('address');
      final docRef = address.docId.isEmpty ? col.doc() : col.doc(address.docId);
      address.docId = docRef.id;
      address.uid = uid;

      if (address.isSelected) {
        final batch = _firestore.batch();
        final prevSelected = await col
            .where('isSelected', isEqualTo: true)
            .get();
        for (final d in prevSelected.docs) {
          if (d.id != address.docId) {
            batch.update(d.reference, {'isSelected': false});
          }
        }
        batch.set(docRef, address.toMap(), SetOptions(merge: true));
        await batch.commit();
      } else {
        await docRef.set(address.toMap(), SetOptions(merge: true));
      }

      Get.snackbar('Success', 'Address saved successfully!');
      return true;
    } catch (e) {
      print('[AddressController] saveAddress error: $e');
      Get.snackbar('Error', 'Failed to save the address: $e');
      return false;
    }
  }

  Future<void> updateAddress(Address address) async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    try {
      final col = _firestore.collection('users').doc(uid).collection('address');
      final docRef = col.doc(address.docId);

      if (address.isSelected) {
        final batch = _firestore.batch();

        // unset others
        final prevSelected = await col
            .where('isSelected', isEqualTo: true)
            .get();
        for (final d in prevSelected.docs) {
          if (d.id != address.docId) {
            batch.update(d.reference, {'isSelected': false});
          }
        }
        batch.update(docRef, address.toMap());
        await batch.commit();
      } else {
        await docRef.update(address.toMap());
      }

      Get.snackbar('Success', 'Address updated successfully!');
    } catch (e) {
      print('[AddressController] updateAddress error: $e');
      Get.snackbar('Error', 'Failed to update the address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    try {
      final col = _firestore.collection('users').doc(uid).collection('address');
      final docRef = col.doc(addressId);

      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        Get.snackbar('Info', 'Address not found.');
        return;
      }

      final wasSelected = (docSnap.data()?['isSelected'] ?? false) as bool;

      // mark deleted
      await docRef.update({'isDeleted': true, 'isSelected': false});

      if (wasSelected) {
        final remaining = await col
            .where('isDeleted', isEqualTo: false)
            .limit(1)
            .get();
        if (remaining.docs.isNotEmpty) {
          await remaining.docs.first.reference.set({
            'isSelected': true,
          }, SetOptions(merge: true));
        } else {
          selectedAddress.value = null;
        }
      }

      Get.snackbar('Success', 'Address deleted successfully!');
    } catch (e) {
      print('[AddressController] deleteAddress error: $e');
      Get.snackbar('Error', 'Failed to delete the address: $e');
    }
  }

  Future<bool> hasAddresses() async {
    try {
      final uid = _uid;
      if (uid == null) return false;
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('address')
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('[AddressController] hasAddresses error: $e');
      return false;
    }
  }

  Address? selectedAddressSync() {
    return selectedAddress.value;
  }
}
