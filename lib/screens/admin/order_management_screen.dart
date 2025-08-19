// screens/admin/order_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    return orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'All' ||
          order.status.name.toLowerCase() == _filterStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Text(
          'Order Management',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadOrders();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoadingOrders) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: AppConstants.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminProvider.error!,
                    style: AppConstants.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadOrders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredOrders = _getFilteredOrders(adminProvider.orders);

          return Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilterSection(),

              // Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(filteredOrders, adminProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search orders by ID, customer name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Filter Options
          DropdownButtonFormField<String>(
            value: _filterStatus,
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
            items: ['All', 'Pending', 'Confirmed', 'Preparing', 'OnTheWay', 'Delivered', 'Cancelled']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status == 'OnTheWay' ? 'On The Way' : status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, AdminProvider adminProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, adminProvider);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, AdminProvider adminProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                // Order Status Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppConstants.spacingMedium),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8)}',
                            style: AppConstants.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusDisplayName(order.status),
                              style: AppConstants.bodySmall.copyWith(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.userName,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        order.userEmail,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Order Details
            Row(
              children: [
                Expanded(
                  child: _buildOrderInfoItem(
                    'Total',
                    '\${order.total.toStringAsFixed(2)}',
                    Icons.monetization_on,
                  ),
                ),
                Expanded(
                  child: _buildOrderInfoItem(
                    'Items',
                    '${order.items.length}',
                    Icons.shopping_cart,
                  ),
                ),
                Expanded(
                  child: _buildOrderInfoItem(
                    'Date',
                    _formatDate(order.createdAt),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),

            if (order.trackingNumber != null) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, size: 16, color: AppConstants.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tracking: ${order.trackingNumber}',
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showOrderDetailsDialog(order),
                  icon: Icon(Icons.info, size: 18, color: AppConstants.primaryColor),
                  label: Text(
                    'Details',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showStatusUpdateDialog(order, adminProvider),
                  icon: Icon(Icons.update, size: 18, color: AppConstants.accentColor),
                  label: Text(
                    'Status',
                    style: TextStyle(color: AppConstants.accentColor),
                  ),
                ),
                if (order.status == OrderStatus.confirmed || order.status == OrderStatus.preparing)
                  TextButton.icon(
                    onPressed: () => _showTrackingDialog(order, adminProvider),
                    icon: Icon(Icons.local_shipping, size: 18, color: AppConstants.successColor),
                    label: Text(
                      'Tracking',
                      style: TextStyle(color: AppConstants.successColor),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppConstants.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: AppConstants.headingMedium.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', order.userName),
              _buildDetailRow('Email', order.userEmail),
              _buildDetailRow('Status', _getStatusDisplayName(order.status)),
              _buildDetailRow('Payment Status', _getPaymentStatusDisplayName(order.paymentStatus)),
              _buildDetailRow('Subtotal', '\${order.subtotal.toStringAsFixed(2)}'),
              _buildDetailRow('Delivery Fee', '\${order.deliveryFee.toStringAsFixed(2)}'),
              _buildDetailRow('Tax', '\${order.tax.toStringAsFixed(2)}'),
              _buildDetailRow('Total Amount', '\${order.total.toStringAsFixed(2)}'),
              _buildDetailRow('Tracking Number', order.trackingNumber ?? 'Not assigned'),
              _buildDetailRow('Shipping Address', order.shippingAddress),
              _buildDetailRow('Order Date', _formatDateTime(order.createdAt)),
              _buildDetailRow('Last Updated', order.updatedAt != null ? _formatDateTime(order.updatedAt!) : 'Never'),

              if (order.deliveryInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Delivery Info:',
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (order.deliveryInfo!.phone != null)
                  _buildDetailRow('Phone', order.deliveryInfo!.phone!),
                if (order.deliveryInfo!.instructions != null)
                  _buildDetailRow('Instructions', order.deliveryInfo!.instructions!),
              ],

              const SizedBox(height: 16),
              Text(
                'Order Items:',
                style: AppConstants.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (item.productImage != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: NetworkImage(item.productImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppConstants.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Qty: ${item.quantity} × \${item.price.toStringAsFixed(2)}',
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\${item.totalPrice.toStringAsFixed(2)}',
                      style: AppConstants.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppConstants.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(OrderModel order, AdminProvider adminProvider) {
    OrderStatus selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current status: ${_getStatusDisplayName(order.status)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<OrderStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Select New Status',
                  border: OutlineInputBorder(),
                ),
                items: OrderStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus == order.status
                  ? null
                  : () async {
                Navigator.of(context).pop();
                final success = await adminProvider.updateOrderStatus(order.id, selectedStatus);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Order status updated successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update order status'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingDialog(OrderModel order, AdminProvider adminProvider) {
    _trackingController.text = order.trackingNumber ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Tracking Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order #${order.id.substring(0, 8)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _trackingController,
              decoration: const InputDecoration(
                labelText: 'Tracking Number',
                hintText: 'Enter tracking number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_trackingController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                final success = await adminProvider.updateTrackingNumber(
                  order.id,
                  _trackingController.text.trim(),
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tracking number updated successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update tracking number'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
                _trackingController.clear();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return AppConstants.primaryColor;
      case OrderStatus.preparing:
        return AppConstants.accentColor;
      case OrderStatus.onTheWay:
        return Colors.blue;
      case OrderStatus.delivered:
        return AppConstants.successColor;
      case OrderStatus.cancelled:
        return AppConstants.errorColor;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.kitchen;
      case OrderStatus.onTheWay:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.onTheWay:
        return 'ON THE WAY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _getPaymentStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}