// screens/product/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../config/constants.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_app_bar.dart';
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
    return Consumer2<ProductProvider, UserProvider>(
      builder: (context, productProvider, userProvider, child) {
        final userInterests = userProvider.userInterests;
        final hasInterests = userInterests.isNotEmpty;

        return Scaffold(
          appBar: CustomAppBar(
            title: hasInterests ? 'Recommended for You' : 'All Products',
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    _currentSort = value;
                  });
                  productProvider.sortProducts(value);
                },
                itemBuilder: (context) => [
                  if (hasInterests)
                    const PopupMenuItem(
                      value: 'personalized',
                      child: Text('Personalized'),
                    ),
                  const PopupMenuItem(
                    value: 'name',
                    child: Text('Name A-Z'),
                  ),
                  const PopupMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low to High'),
                  ),
                  const PopupMenuItem(
                    value: 'price_high',
                    child: Text('Price: High to Low'),
                  ),
                  const PopupMenuItem(
                    value: 'rating',
                    child: Text('Highest Rated'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                color: Colors.white,
                child: Column(
                  children: [
                    // Personalization indicator
                    if (hasInterests)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing products based on your interests: ${userInterests.join(", ")}',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            productProvider.clearSearch();
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                      ),
                      onChanged: (value) {
                        productProvider.searchProducts(value);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),

                    // Category Filter with interest indication
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = productProvider.categories[index];
                          final isSelected = productProvider.selectedCategory == category;
                          final isUserInterest = category != 'All' &&
                              productProvider.isUserInterest(category);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isUserInterest && !isSelected)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(category),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                productProvider.filterByCategory(category);
                              },
                              selectedColor: isUserInterest
                                  ? Colors.blue.withOpacity(0.2)
                                  : AppConstants.primaryColor.withOpacity(0.2),
                              checkmarkColor: isUserInterest
                                  ? Colors.blue
                                  : AppConstants.primaryColor,
                              backgroundColor: isUserInterest && !isSelected
                                  ? Colors.blue.withOpacity(0.05)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Current sort indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[50],
                child: Text(
                  'Sorted by: ${_getSortDisplayName(_currentSort)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Products Grid
              Expanded(
                child: productProvider.isLoading
                    ? const LoadingIndicator(message: 'Loading personalized products...')
                    : productProvider.filteredProducts.isEmpty
                    ? _buildEmptyState(hasInterests, userInterests)
                    : GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                  ),
                  itemCount: productProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.filteredProducts[index];
                    final isUserInterest = productProvider.isUserInterest(product.category);

                    return ProductCard(
                      product: product,
                      isRecommended: isUserInterest,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasInterests
                ? 'No products found matching your search'
                : 'No products found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (hasInterests)
            Text(
              'Try adjusting your search or browse different categories',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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