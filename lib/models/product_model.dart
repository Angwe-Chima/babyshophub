// models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // For sale price comparison
  final String imageUrl;
  final String category;
  final double rating;
  final bool isOnSale;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.isOnSale = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice'] != null ? (map['originalPrice']).toDouble() : null,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      isOnSale: map['isOnSale'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'isOnSale': isOnSale,
    };
  }
}