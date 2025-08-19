// order_service.dart - Updated and fixed version
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'orders';

  // Create new order
  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      var orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory by createdAt descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw Exception('Error fetching user orders: $e');
    }
  }

  // Get single order
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory by createdAt descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Get user orders in real-time
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory by createdAt descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Get all orders (admin function)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory by createdAt descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }
}