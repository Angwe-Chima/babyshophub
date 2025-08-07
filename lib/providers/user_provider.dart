import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if user has completed onboarding
  bool get hasCompletedOnboarding {
    return _currentUser?.hasCompletedOnboarding ?? false;
  }

  // Get user interests
  List<String> get userInterests {
    return _currentUser?.interests ?? [];
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

  // Create new user (with onboarding incomplete by default)
  Future<void> createUser({
    required String uid,
    required String email,
    String? name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = UserModel(
        uid: uid,
        name: name ?? email.split('@')[0],
        email: email,
        interests: [],
        hasCompletedOnboarding: false,
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

  // Mark that user has seen onboarding screens
  Future<void> markOnboardingSeen() async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(hasCompletedOnboarding: true);
      await UserService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Update user interests and complete the full onboarding process
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
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear user data
  void clearUser() {
    _currentUser = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Check if user document exists in Firestore
  Future<bool> checkUserExists(String uid) async {
    try {
      return await UserService.userExists(uid);
    } catch (e) {
      return false;
    }
  }

  // Add interests without marking onboarding as complete
  Future<void> addInterests(List<String> interests) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(interests: interests);
      await UserService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}