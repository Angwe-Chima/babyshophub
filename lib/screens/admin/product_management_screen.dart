// screens/admin/product_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).refreshProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _filterCategory == 'All' ||
          product.category.toLowerCase() == _filterCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Text(
          'Product Management',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).refreshProducts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer2<AdminProvider, ProductProvider>(
        builder: (context, adminProvider, productProvider, child) {
          if (productProvider.isLoading) {
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
                    'Error loading products',
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
                    onPressed: () => productProvider.refreshProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredProducts = _getFilteredProducts(productProvider.products);

          return Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilterSection(),

              // Products List
              Expanded(
                child: filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(filteredProducts, adminProvider),
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
              hintText: 'Search products by name or description...',
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
            value: _filterCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
            items: ['All', 'Baby Food', 'Toys', 'Clothing', 'Care', 'Feeding']
                .map((category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filterCategory = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductModel> products, AdminProvider adminProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, adminProvider);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, AdminProvider adminProvider) {
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
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: AppConstants.spacingMedium),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppConstants.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          if (product.isOnSale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ON SALE',
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.errorColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        product.description,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // Product Details
            Row(
              children: [
                Expanded(
                  child: _buildProductInfoItem(
                    'Price',
                    product.isOnSale && product.originalPrice != null
                        ? '\$${product.price.toStringAsFixed(2)}'
                        : '\$${product.price.toStringAsFixed(2)}',
                    Icons.monetization_on,
                  ),
                ),
                if (product.originalPrice != null && product.isOnSale)
                  Expanded(
                    child: _buildProductInfoItem(
                      'Original',
                      '\$${product.originalPrice!.toStringAsFixed(2)}',
                      Icons.price_change,
                    ),
                  ),
                Expanded(
                  child: _buildProductInfoItem(
                    'Rating',
                    product.rating.toStringAsFixed(1),
                    Icons.star,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditProductDialog(product, adminProvider),
                  icon: Icon(Icons.edit, size: 18, color: AppConstants.primaryColor),
                  label: Text(
                    'Edit',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(product, adminProvider),
                  icon: Icon(Icons.delete, size: 18, color: AppConstants.errorColor),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: AppConstants.errorColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoItem(String label, String value, IconData icon) {
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
            Icons.inventory_2_outlined,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
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

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final originalPriceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final ratingController = TextEditingController();
    String selectedCategory = 'Baby Food';
    bool isOnSale = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Baby Food', 'Toys', 'Clothing', 'Care', 'Feeding']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                CheckboxListTile(
                  title: const Text('On Sale'),
                  value: isOnSale,
                  onChanged: (value) {
                    setState(() {
                      isOnSale = value!;
                    });
                  },
                ),
                if (isOnSale) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  TextField(
                    controller: originalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Original Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating (0-5)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty &&
                    priceController.text.trim().isNotEmpty &&
                    imageUrlController.text.trim().isNotEmpty &&
                    ratingController.text.trim().isNotEmpty) {

                  final product = ProductModel(
                    id: '',
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: selectedCategory,
                    price: double.parse(priceController.text),
                    originalPrice: isOnSale && originalPriceController.text.trim().isNotEmpty
                        ? double.parse(originalPriceController.text)
                        : null,
                    imageUrl: imageUrlController.text.trim(),
                    rating: double.parse(ratingController.text),
                    isOnSale: isOnSale,
                  );

                  Navigator.of(context).pop();
                  final success = await Provider.of<AdminProvider>(context, listen: false)
                      .addProduct(product);

                  if (success) {
                    // Refresh the product list
                    Provider.of<ProductProvider>(context, listen: false).refreshProducts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Product added successfully'),
                        backgroundColor: AppConstants.successColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to add product'),
                        backgroundColor: AppConstants.errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(ProductModel product, AdminProvider adminProvider) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final originalPriceController = TextEditingController(text: product.originalPrice?.toString() ?? '');
    final imageUrlController = TextEditingController(text: product.imageUrl);
    final ratingController = TextEditingController(text: product.rating.toString());
    String selectedCategory = product.category;
    bool isOnSale = product.isOnSale;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Baby Food', 'Toys', 'Clothing', 'Care', 'Feeding']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                CheckboxListTile(
                  title: const Text('On Sale'),
                  value: isOnSale,
                  onChanged: (value) {
                    setState(() {
                      isOnSale = value!;
                    });
                  },
                ),
                if (isOnSale) ...[
                  const SizedBox(height: AppConstants.spacingMedium),
                  TextField(
                    controller: originalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Original Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating (0-5)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty &&
                    priceController.text.trim().isNotEmpty &&
                    imageUrlController.text.trim().isNotEmpty &&
                    ratingController.text.trim().isNotEmpty) {

                  final updatedProduct = ProductModel(
                    id: product.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: selectedCategory,
                    price: double.parse(priceController.text),
                    originalPrice: isOnSale && originalPriceController.text.trim().isNotEmpty
                        ? double.parse(originalPriceController.text)
                        : null,
                    imageUrl: imageUrlController.text.trim(),
                    rating: double.parse(ratingController.text),
                    isOnSale: isOnSale,
                  );

                  Navigator.of(context).pop();
                  final success = await adminProvider.updateProduct(product.id, updatedProduct);

                  if (success) {
                    // Refresh the product list
                    Provider.of<ProductProvider>(context, listen: false).refreshProducts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Product updated successfully'),
                        backgroundColor: AppConstants.successColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to update product'),
                        backgroundColor: AppConstants.errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ProductModel product, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await adminProvider.deleteProduct(product.id);

              if (success) {
                // Refresh the product list
                Provider.of<ProductProvider>(context, listen: false).refreshProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Product deleted successfully'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to delete product'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}