// services/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Get all products
  static Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get products by category
  static Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get single product by ID
  static Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Search products
  static Stream<List<ProductModel>> searchProducts(String query) {
    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get featured products (high rating)
  static Stream<List<ProductModel>> getFeaturedProducts() {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThanOrEqualTo: 4.0)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Add product (admin function)
  static Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).add(product.toMap());
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // Update product (admin function)
  static Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(productId)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Delete product (admin function)
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}