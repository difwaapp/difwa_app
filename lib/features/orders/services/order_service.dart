import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.orderId).set(order.toMap());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': status,
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<bool> verifyOtp(String orderId, String otp) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        String storedOtp = doc['deliveryOtp'];
        return storedOtp == otp;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }
}
