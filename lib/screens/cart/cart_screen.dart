// screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../config/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import './checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Shopping Cart (${cartProvider.itemCount})',
            actions: cartProvider.items.isNotEmpty
                ? [
              TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cartProvider);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ]
                : null,
          ),
          body: cartProvider.isEmpty
              ? _buildEmptyCart(context)
              : Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _buildCartItem(context, cartProvider, item, index);
                  },
                ),
              ),
              // Cart Summary
              _buildCartSummary(context, cartProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: AppConstants.headingMedium.copyWith(
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some amazing products for your little one',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Start Shopping',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.shopping_bag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cartProvider, dynamic item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppConstants.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: AppConstants.headingSmall.copyWith(
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (item.quantity > 1) {
                            cartProvider.decreaseQuantity(item.productId);
                          } else {
                            _showRemoveItemDialog(context, cartProvider, item);
                          }
                        },
                        backgroundColor: Colors.grey[200],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppConstants.borderColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.quantity.toString(),
                          style: AppConstants.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          cartProvider.increaseQuantity(item.productId);
                        },
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Item Total and Delete Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    _showRemoveItemDialog(context, cartProvider, item);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: AppConstants.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppConstants.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Details
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items:',
                        style: AppConstants.bodyLarge.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      Text(
                        cartProvider.totalQuantity.toString(),
                        style: AppConstants.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: AppConstants.bodyLarge.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                        style: AppConstants.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee:',
                        style: AppConstants.bodyLarge.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      Text(
                        cartProvider.totalAmount >= 50 ? 'FREE' : '\$5.00',
                        style: AppConstants.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cartProvider.totalAmount >= 50
                              ? AppConstants.successColor
                              : AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (cartProvider.totalAmount < 50) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Add \$${(50 - cartProvider.totalAmount).toStringAsFixed(2)} more for free delivery',
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: AppConstants.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_calculateTotal(cartProvider).toStringAsFixed(2)}',
                        style: AppConstants.headingMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            // Checkout Button
            CustomButton(
              text: 'Proceed to Checkout',
              width: double.infinity,
              icon: Icons.payment,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(CartProvider cartProvider) {
    final subtotal = cartProvider.totalAmount;
    final deliveryFee = subtotal >= 50 ? 0.0 : 5.0;
    return subtotal + deliveryFee;
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared successfully'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, CartProvider cartProvider, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        title: const Text('Remove Item'),
        content: Text(
          'Remove "${item.name}" from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              cartProvider.removeFromCart(item.productId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed from cart'),
                  backgroundColor: AppConstants.errorColor,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // Add back to cart logic here if needed
                    },
                  ),
                ),
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}