// ======================= screens/product/product_detail_screen.dart =======================
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../config/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: product.name,
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[100],
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: AppConstants.headingMedium,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      // Rating and Category
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: AppConstants.bodyLarge,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            child: Text(
                              product.category,
                              style: AppConstants.bodyMedium.copyWith(
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      // Price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppConstants.headingLarge.copyWith(
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      // Description
                      Text(
                        'Description',
                        style: AppConstants.headingSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        product.description,
                        style: AppConstants.bodyLarge,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: AppConstants.paddingExtraLarge),
                      // Quantity Selector (if item is in cart)
                      if (cartProvider.isInCart(product.id)) ...[
                        Text(
                          'Quantity in Cart',
                          style: AppConstants.headingSmall,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                cartProvider.decreaseQuantity(product.id);
                              },
                              icon: const Icon(Icons.remove),
                              style: IconButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              cartProvider.getQuantity(product.id).toString(),
                              style: AppConstants.headingMedium,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {
                                cartProvider.increaseQuantity(product.id);
                              },
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
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
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: cartProvider.isInCart(product.id)
                        ? 'Remove from Cart'
                        : 'Add to Cart',
                    backgroundColor: cartProvider.isInCart(product.id)
                        ? AppConstants.errorColor
                        : AppConstants.primaryColor,
                    icon: cartProvider.isInCart(product.id)
                        ? Icons.remove_shopping_cart
                        : Icons.add_shopping_cart,
                    onPressed: () {
                      if (cartProvider.isInCart(product.id)) {
                        cartProvider.removeFromCart(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from cart!'),
                            backgroundColor: AppConstants.errorColor,
                          ),
                        );
                      } else {
                        cartProvider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            backgroundColor: AppConstants.successColor,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}