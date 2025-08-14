// screens/product/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_app_bar.dart';
import '../cart/cart_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSort = 'personalized';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // Initialize products with user interests
      productProvider.initialize(userInterests: userProvider.userInterests);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, UserProvider, AuthProvider>(
      builder: (context, productProvider, userProvider, authProvider, child) {
        final userInterests = userProvider.userInterests;
        final hasInterests = userInterests.isNotEmpty;

        // Get user name from auth provider
        String userName = 'Guest';
        if (authProvider.user?.displayName != null && authProvider.user!.displayName!.isNotEmpty) {
          userName = authProvider.user!.displayName!.split(' ').first; // Get first name only
        } else if (authProvider.user?.email != null) {
          // Extract name from email if display name is not available
          userName = authProvider.user!.email!.split('@').first;
          // Capitalize first letter
          userName = userName[0].toUpperCase() + userName.substring(1);
        }

        return Scaffold(
          backgroundColor: AppConstants.neutralColor,
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header with greeting and cart
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting and cart row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi $userName,',
                                style: AppConstants.headingMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasInterests ? 'Find your favorite products' : 'Explore our collection',
                                style: AppConstants.bodyMedium,
                              ),
                            ],
                          ),
                          _buildCartIcon(context),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: AppConstants.bodyMedium,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppConstants.textSecondary,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // Sort/filter action
                                  _showSortBottomSheet(context, productProvider, hasInterests);
                                },
                                icon: const Icon(Icons.tune),
                                color: Colors.white,
                                iconSize: 20,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            productProvider.searchProducts(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Featured Product Card (like the discount banner in design)
                if (hasInterests)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '20% Off',
                                  style: AppConstants.discountStyle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Special offers\nfor $userName!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Based on your interests: ${userInterests.join(", ")}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Popular Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular',
                        style: AppConstants.headingSmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show all products
                        },
                        child: Text(
                          'See All',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Products Grid
                Expanded(
                  child: productProvider.isLoading
                      ? const LoadingIndicator(message: 'Loading personalized products...')
                      : productProvider.filteredProducts.isEmpty
                      ? _buildEmptyState(hasInterests, userInterests)
                      : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.filteredProducts[index];
                      final isUserInterest = productProvider.isUserInterest(product.category);

                      return _buildProductCard(
                        context,
                        product,
                        isUserInterest,
                      );
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

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                color: AppConstants.textPrimary,
              ),
            ),
            if (cartProvider.totalQuantity > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    cartProvider.totalQuantity > 99 ? '99+' : '${cartProvider.totalQuantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, bool isRecommended) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with favorite button
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundSecondary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: AppConstants.textLight,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ),
                        if (isRecommended)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppConstants.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category,
                              style: AppConstants.bodySmall,
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: AppConstants.priceStyle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (cartProvider.isInCart(product.id)) {
                                  cartProvider.removeFromCart(product.id);
                                } else {
                                  cartProvider.addToCart(product);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cartProvider.isInCart(product.id)
                                      ? AppConstants.primaryColor
                                      : AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  cartProvider.isInCart(product.id)
                                      ? Icons.check
                                      : Icons.add,
                                  size: 20,
                                  color: cartProvider.isInCart(product.id)
                                      ? Colors.white
                                      : AppConstants.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context, ProductProvider productProvider, bool hasInterests) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: AppConstants.headingSmall,
            ),
            const SizedBox(height: 16),
            if (hasInterests)
              _buildSortOption('Personalized', 'personalized', productProvider),
            _buildSortOption('Name A-Z', 'name', productProvider),
            _buildSortOption('Price: Low to High', 'price_low', productProvider),
            _buildSortOption('Price: High to Low', 'price_high', productProvider),
            _buildSortOption('Highest Rated', 'rating', productProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value, ProductProvider productProvider) {
    final isSelected = _currentSort == value;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: AppConstants.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _currentSort = value;
        });
        productProvider.sortProducts(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState(bool hasInterests, List<String> userInterests) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasInterests ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            hasInterests
                ? 'No products found matching your search'
                : 'No products found',
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (hasInterests)
            Text(
              'Try adjusting your search or browse different categories',
              style: AppConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'personalized':
        return 'Personalized';
      case 'name':
        return 'Name A-Z';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Highest Rated';
      default:
        return 'Default';
    }
  }
}