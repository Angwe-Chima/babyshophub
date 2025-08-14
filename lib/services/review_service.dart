// services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'reviews';

  // Add a new review
  static Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.collection(_collection).add(review.toMap());

      // Update product rating
      await _updateProductRating(review.productId);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get reviews for a specific product
  static Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get user's review for a specific product
  static Future<ReviewModel?> getUserReviewForProduct(String userId, String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ReviewModel.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user review: $e');
    }
  }

  // Update an existing review
  static Future<void> updateReview(String reviewId, ReviewModel review) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(reviewId)
          .update(review.toMap());

      // Update product rating
      await _updateProductRating(review.productId);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  // Delete a review
  static Future<void> deleteReview(String reviewId, String productId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).delete();

      // Update product rating
      await _updateProductRating(productId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Get average rating for a product
  static Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      double totalRating = 0;
      Map<int, int> ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var doc in querySnapshot.docs) {
        final rating = (doc.data()['rating'] ?? 0).toDouble();
        totalRating += rating;
        ratingDistribution[rating.round()] =
            (ratingDistribution[rating.round()] ?? 0) + 1;
      }

      return {
        'averageRating': totalRating / querySnapshot.docs.length,
        'totalReviews': querySnapshot.docs.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      throw Exception('Failed to get rating stats: $e');
    }
  }

  // Update product rating in the products collection
  static Future<void> _updateProductRating(String productId) async {
    try {
      final stats = await getProductRatingStats(productId);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'rating': stats['averageRating'],
        'totalReviews': stats['totalReviews'],
      });
    } catch (e) {
      // Don't throw error as this is a background operation
      print('Failed to update product rating: $e');
    }
  }

  // Check if user has reviewed a product
  static Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get all reviews by a user
  static Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}