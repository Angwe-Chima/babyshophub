// order_detail_screen.dart - Complete implementation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel order;
  final OrderService _orderService = OrderService();
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      await _orderService.cancelOrder(order.id);
      setState(() {
        order = order.copyWith(status: OrderStatus.cancelled);
        _isCancelling = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCancelling = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order #${order.id.substring(0, 8)}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildOrderStatusCard(),
            const SizedBox(height: 16.0),

            // Order Timeline (if not cancelled)
            if (order.status != OrderStatus.cancelled)
              _buildOrderTimeline(),

            if (order.status != OrderStatus.cancelled)
              const SizedBox(height: 16.0),

            // Order Items
            _buildOrderItemsCard(),
            const SizedBox(height: 16.0),

            // Delivery Information
            if (order.deliveryInfo != null)
              _buildDeliveryInfoCard(),

            if (order.deliveryInfo != null)
              const SizedBox(height: 16.0),

            // Order Summary
            _buildOrderSummaryCard(),
            const SizedBox(height: 16.0),

            // Action Buttons
            if (order.status == OrderStatus.pending) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    Color statusColor;
    String statusText = order.status.toString().split('.').last.toUpperCase();

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        break;
      case OrderStatus.preparing:
        statusColor = Colors.purple;
        break;
      case OrderStatus.onTheWay:
        statusColor = Colors.teal;
        statusText = 'ON THE WAY';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final steps = [
      {'status': OrderStatus.pending, 'title': 'Order Placed', 'icon': Icons.receipt},
      {'status': OrderStatus.confirmed, 'title': 'Confirmed', 'icon': Icons.check_circle},
      {'status': OrderStatus.preparing, 'title': 'Preparing', 'icon': Icons.restaurant},
      {'status': OrderStatus.onTheWay, 'title': 'On the Way', 'icon': Icons.delivery_dining},
      {'status': OrderStatus.delivered, 'title': 'Delivered', 'icon': Icons.done_all},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...steps.map((step) => _buildTimelineStep(step)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step) {
    final isCompleted = order.status.index >= (step['status'] as OrderStatus).index;
    final isCurrent = order.status == step['status'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              border: Border.all(
                color: isCurrent ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              step['icon'],
              size: 14,
              color: isCompleted ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            step['title'],
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCompleted ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (item.productImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.productImage!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fastfood),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(order.deliveryInfo!.address),
                ),
              ],
            ),
            if (order.deliveryInfo!.phone != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(order.deliveryInfo!.phone!),
                ],
              ),
            ],
            if (order.deliveryInfo!.instructions != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(order.deliveryInfo!.instructions!),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', order.subtotal),
            _buildSummaryRow('Delivery Fee', order.deliveryFee),
            _buildSummaryRow('Tax', order.tax),
            const Divider(),
            _buildSummaryRow('Total', order.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancelOrderDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isCancelling
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text('Cancel Order'),
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id.substring(0, 8)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, Keep Order',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelOrder();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}