// providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCompletedOnboarding => _currentUser?.hasCompletedOnboarding ?? false;
  List<String> get userInterests => _currentUser?.interests ?? [];
  String get userDisplayName => _currentUser?.displayName ?? '';
  String get userFullName => _currentUser?.fullName ?? '';

  // Set user data (the missing method)
  void setUser(UserModel user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  // Load user data
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await UserService.getUser(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create user with basic info (for simple signup)
  Future<void> createUser({
    required String uid,
    required String email,
    String? name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Split name into first and last name
      final nameParts = (name ?? email.split('@')[0]).split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final user = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        interests: [],
        hasCompletedOnboarding: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await UserService.createUser(user);
      _currentUser = user;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create user with full registration data
  Future<void> createUserWithRegistrationData({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.createUserWithRegistrationData(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      // Load the created user
      await loadUser(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.updateUserProfile(
        uid: _currentUser!.uid,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
      );

      // Update local user data
      _currentUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        phone: phone ?? _currentUser!.phone,
        dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
        gender: gender ?? _currentUser!.gender,
        address: address ?? _currentUser!.address,
        updatedAt: DateTime.now(),
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    if (_currentUser == null) return;

    try {
      await UserService.markOnboardingCompleted(_currentUser!.uid);
      _currentUser = _currentUser!.copyWith(
        hasCompletedOnboarding: true,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Update user interests
  Future<void> updateUserInterests(List<String> interests) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.updateUserInterests(_currentUser!.uid, interests);
      _currentUser = _currentUser!.copyWith(
        interests: interests,
        hasCompletedOnboarding: true,
        updatedAt: DateTime.now(),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update full user data
  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.updateUser(user);
      _currentUser = user.copyWith(updatedAt: DateTime.now());
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear user data (on logout)
  void clearUser() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Check if user exists
  Future<bool> checkUserExists(String uid) async {
    try {
      return await UserService.userExists(uid);
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await loadUser(_currentUser!.uid);
    }
  }
}