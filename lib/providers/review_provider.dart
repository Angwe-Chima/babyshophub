// providers/review_provider.dart
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviews = [];
  ReviewModel? _userReview;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _ratingStats = {};

  // Getters
  List<ReviewModel> get reviews => _reviews;
  ReviewModel? get userReview => _userReview;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get ratingStats => _ratingStats;

  double get averageRating => _ratingStats['averageRating']?.toDouble() ?? 0.0;
  int get totalReviews => _ratingStats['totalReviews']?.toInt() ?? 0;
  Map<int, int> get ratingDistribution =>
      Map<int, int>.from(_ratingStats['ratingDistribution'] ?? {});

  // Load reviews for a product
  void loadProductReviews(String productId) {
    ReviewService.getProductReviews(productId).listen(
          (reviews) {
        _reviews = reviews;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load rating stats for a product
  Future<void> loadRatingStats(String productId) async {
    try {
      _ratingStats = await ReviewService.getProductRatingStats(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user's review for a product
  Future<void> loadUserReview(String userId, String productId) async {
    try {
      _userReview = await ReviewService.getUserReviewForProduct(userId, productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add a new review
  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await ReviewService.addReview(review);

      // Reload user review and stats
      await loadUserReview(userId, productId);
      await loadRatingStats(productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing review
  Future<bool> updateReview({
    required String reviewId,
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = ReviewModel(
        id: reviewId,
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: _userReview?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ReviewService.updateReview(reviewId, review);

      // Reload user review and stats
      await loadUserReview(userId, productId);
      await loadRatingStats(productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId, String productId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ReviewService.deleteReview(reviewId, productId);

      // Clear user review and reload stats
      _userReview = null;
      await loadRatingStats(productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user has reviewed product - using existing userReview data
  Future<bool> hasUserReviewed(String userId, String productId) async {
    try {
      // If userReview is already loaded and matches the criteria, return true
      if (_userReview != null &&
          _userReview!.userId == userId &&
          _userReview!.productId == productId) {
        return true;
      }

      // Otherwise, load user review and check
      await loadUserReview(userId, productId);
      return _userReview != null;
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _reviews.clear();
    _userReview = null;
    _ratingStats.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}