// providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../services/product_service.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  bool get isEmpty => _items.isEmpty;

  CartProvider() {
    _loadCart();
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      ));
    }

    notifyListeners();
    await _saveCart();
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
    await _saveCart();
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity = quantity;
      notifyListeners();
      await _saveCart();
    }
  }

  // Increase quantity
  Future<void> increaseQuantity(String productId) async {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      notifyListeners();
      await _saveCart();
    }
  }

  // Decrease quantity
  Future<void> decreaseQuantity(String productId) async {
    final existingIndex = _items.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        await removeFromCart(productId);
        return;
      }
      notifyListeners();
      await _saveCart();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Get item quantity
  int getQuantity(String productId) {
    final item = _items.firstWhere(
          (item) => item.productId == productId,
      orElse: () => CartItem(productId: '', name: '', price: 0, imageUrl: '', quantity: 0),
    );
    return item.quantity;
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart', json.encode(cartJson));
  }

  // Load cart from local storage
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');

    if (cartString != null) {
      final cartJson = json.decode(cartString) as List;
      _items = cartJson.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }
}