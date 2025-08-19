// providers/admin_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/support_ticket_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Management
  List<UserModel> _users = [];
  bool _isLoadingUsers = false;

  // Products Management
  bool _isLoadingProducts = false;

  // Orders Management
  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;

  // Support Tickets Management
  List<SupportTicketModel> _supportTickets = [];
  bool _isLoadingSupportTickets = false;

  // Statistics
  Map<String, dynamic> _dashboardStats = {};

  String? _error;

  // Getters
  List<UserModel> get users => _users;
  List<OrderModel> get orders => _orders;
  List<SupportTicketModel> get supportTickets => _supportTickets;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingSupportTickets => _isLoadingSupportTickets;

  String? get error => _error;

  // =================== USER MANAGEMENT ===================

  // Load all users
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _error = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load users: $e';
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  // Update user status (activate/deactivate)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      final userIndex = _users.indexWhere((user) => user.uid == userId);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(
          isActive: isActive,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update user status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      final userIndex = _users.indexWhere((user) => user.uid == userId);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(
          role: role,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update user role: $e';
      notifyListeners();
      return false;
    }
  }

  // =================== PRODUCT MANAGEMENT ===================

  // Add new product
  Future<bool> addProduct(ProductModel product) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('products').add(product.toMap());
      _error = null;
      _isLoadingProducts = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add product: $e';
      _isLoadingProducts = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(String productId, ProductModel product) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('products').doc(productId).update(product.toMap());
      _error = null;
      _isLoadingProducts = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update product: $e';
      _isLoadingProducts = false;
      notifyListeners();
      return false;
    }
  }

  // Update product inventory
  Future<bool> updateProductInventory(String productId, int stock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': stock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _error = 'Failed to update inventory: $e';
      notifyListeners();
      return false;
    }
  }

  // Update product price
  Future<bool> updateProductPrice(String productId, double price) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      _error = 'Failed to update price: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('products').doc(productId).delete();
      _error = null;
      _isLoadingProducts = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete product: $e';
      _isLoadingProducts = false;
      notifyListeners();
      return false;
    }
  }

  // =================== ORDER MANAGEMENT ===================

  // Load all orders
  Future<void> loadOrders() async {
    _isLoadingOrders = true;
    _error = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update order status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update order tracking number
  Future<bool> updateTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          trackingNumber: trackingNumber,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update tracking number: $e';
      notifyListeners();
      return false;
    }
  }

  // =================== SUPPORT TICKET MANAGEMENT ===================

  // Load all support tickets
  Future<void> loadSupportTickets() async {
    _isLoadingSupportTickets = true;
    _error = null;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('support_tickets')
          .orderBy('createdAt', descending: true)
          .get();

      _supportTickets = snapshot.docs
          .map((doc) => SupportTicketModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load support tickets: $e';
    } finally {
      _isLoadingSupportTickets = false;
      notifyListeners();
    }
  }

  // Create support ticket (for users)
  Future<bool> createSupportTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String subject,
    required String message,
    TicketPriority priority = TicketPriority.medium,
  }) async {
    try {
      final ticket = SupportTicketModel(
        id: '',
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        subject: subject,
        message: message,
        status: TicketStatus.open,
        priority: priority,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('support_tickets').add(ticket.toMap());
      return true;
    } catch (e) {
      _error = 'Failed to create support ticket: $e';
      notifyListeners();
      return false;
    }
  }

  // Update support ticket status
  Future<bool> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == TicketStatus.resolved || status == TicketStatus.closed) {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('support_tickets').doc(ticketId).update(updateData);

      // Update local data
      final ticketIndex = _supportTickets.indexWhere((ticket) => ticket.id == ticketId);
      if (ticketIndex != -1) {
        _supportTickets[ticketIndex] = _supportTickets[ticketIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          resolvedAt: (status == TicketStatus.resolved || status == TicketStatus.closed)
              ? DateTime.now() : null,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to update ticket status: $e';
      notifyListeners();
      return false;
    }
  }

  // Add admin response to support ticket
  Future<bool> addAdminResponse(String ticketId, String response, String adminId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'adminResponse': response,
        'adminId': adminId,
        'status': TicketStatus.inProgress.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      final ticketIndex = _supportTickets.indexWhere((ticket) => ticket.id == ticketId);
      if (ticketIndex != -1) {
        _supportTickets[ticketIndex] = _supportTickets[ticketIndex].copyWith(
          adminResponse: response,
          adminId: adminId,
          status: TicketStatus.inProgress,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Failed to add admin response: $e';
      notifyListeners();
      return false;
    }
  }

  // =================== DASHBOARD STATISTICS ===================

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      // Get user statistics
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isActive'] ?? true;
      }).length;

      // Get product statistics
      final productsSnapshot = await _firestore.collection('products').get();
      final totalProducts = productsSnapshot.docs.length;
      final lowStockProducts = productsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['stock'] ?? 0) < 10;
      }).length;

      // Get order statistics
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30))))
          .get();
      final monthlyOrders = ordersSnapshot.docs.length;

      final totalRevenue = ordersSnapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['totalAmount'] ?? 0.0);
      });

      // Get support ticket statistics
      final ticketsSnapshot = await _firestore
          .collection('support_tickets')
          .where('status', isEqualTo: TicketStatus.open.name)
          .get();
      final openTickets = ticketsSnapshot.docs.length;

      _dashboardStats = {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'monthlyOrders': monthlyOrders,
        'totalRevenue': totalRevenue,
        'openTickets': openTickets,
      };

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard statistics: $e';
      notifyListeners();
    }
  }

  // =================== UTILITY METHODS ===================

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadUsers(),
      loadOrders(),
      loadSupportTickets(),
      loadDashboardStats(),
    ]);
  }

  // Get filtered orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get filtered support tickets by status
  List<SupportTicketModel> getTicketsByStatus(TicketStatus status) {
    return _supportTickets.where((ticket) => ticket.status == status).toList();
  }

  // Get recent activity
  List<Map<String, dynamic>> getRecentActivity() {
    List<Map<String, dynamic>> activities = [];

    // Add recent orders
    for (var order in _orders.take(5)) {
      activities.add({
        'type': 'order',
        'title': 'New Order #${order.id.substring(0, 8)}',
        'description': 'Order placed by ${order.userName}',
        'timestamp': order.createdAt,
        'data': order,
      });
    }

    // Add recent support tickets
    for (var ticket in _supportTickets.take(5)) {
      activities.add({
        'type': 'ticket',
        'title': 'Support Ticket: ${ticket.subject}',
        'description': 'Submitted by ${ticket.userName}',
        'timestamp': ticket.createdAt,
        'data': ticket,
      });
    }

    // Sort by timestamp
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return activities.take(10).toList();
  }
}