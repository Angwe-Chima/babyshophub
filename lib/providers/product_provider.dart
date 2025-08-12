import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _personalizedProducts = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _userInterests = [];

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get personalizedProducts => _personalizedProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Categories
  final List<String> _categories = [
    'All',
    'Diapers & Wipes',
    'Baby Clothing',
    'Toys & Games',
    'Feeding',
    'Baby Care',
    'Nursery',
    'Safety',
    'Health',
    'Travel & Gear',
    'Books',
  ];

  List<String> get categories => _categories;

  // Initialize products with user interests
  void initialize({List<String>? userInterests}) {
    _userInterests = userInterests ?? [];
    _loadProducts();
    _loadFeaturedProducts();
  }

  // Load all products
  void _loadProducts() {
    _isLoading = true;
    notifyListeners();

    ProductService.getProducts().listen((products) {
      _products = products;
      _createPersonalizedProducts();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    }).onError((error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading products: $error');
    });
  }

  // Create personalized product list based on user interests
  void _createPersonalizedProducts() {
    if (_userInterests.isEmpty) {
      _personalizedProducts = List.from(_products);
      return;
    }

    // Separate products into interested and others
    List<ProductModel> interestedProducts = [];
    List<ProductModel> otherProducts = [];

    for (var product in _products) {
      if (_userInterests.contains(product.category)) {
        interestedProducts.add(product);
      } else {
        otherProducts.add(product);
      }
    }

    // Sort interested products by rating (highest first)
    interestedProducts.sort((a, b) => b.rating.compareTo(a.rating));

    // Combine: interested products first, then others
    _personalizedProducts = [...interestedProducts, ...otherProducts];
  }

  // Load featured products
  void _loadFeaturedProducts() {
    ProductService.getFeaturedProducts().listen((products) {
      _featuredProducts = products;
      notifyListeners();
    }).onError((error) {
      debugPrint('Error loading featured products: $error');
    });
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters with personalization priority
  void _applyFilters() {
    List<ProductModel> sourceList = _personalizedProducts.isNotEmpty
        ? _personalizedProducts
        : _products;

    _filteredProducts = sourceList.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);

      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // If filtering by user's interested category, sort by rating
    if (_selectedCategory != 'All' && _userInterests.contains(_selectedCategory)) {
      _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  // Update user interests and refresh personalization
  void updateUserInterests(List<String> interests) {
    _userInterests = interests;
    _createPersonalizedProducts();
    _applyFilters();
    notifyListeners();
  }

  // Get product by ID
  Future<void> getProductById(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await ProductService.getProduct(productId);
    } catch (e) {
      debugPrint('Error getting product: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Get products by category (stream)
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return ProductService.getProductsByCategory(category);
  }

  // Refresh products
  void refreshProducts() {
    _loadProducts();
    _loadFeaturedProducts();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _applyFilters();
    notifyListeners();
  }

  // Sort products with personalization consideration
  void sortProducts(String sortBy) {
    switch (sortBy) {
      case 'personalized':
        _filteredProducts = _personalizedProducts.where((product) {
          final matchesSearch = _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery) ||
              product.description.toLowerCase().contains(_searchQuery);
          final matchesCategory = _selectedCategory == 'All' ||
              product.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
        break;
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    notifyListeners();
  }

  // Check if category is user's interest
  bool isUserInterest(String category) {
    return _userInterests.contains(category);
  }

  // Get user interests count
  int get userInterestsCount => _userInterests.length;
}