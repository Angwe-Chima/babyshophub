import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  bool get isLoggedIn => _user != null;

  // Track if user just signed up (to show onboarding)
  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;

  AuthProvider() {
    AuthService.auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _user = await _authService.signIn(email, password);
    _isNewUser = false; // Existing user login
    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    _user = await _authService.signUp(email, password);
    _isNewUser = true; // New user signup
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _user = await _authService.signInWithGoogle();
    // Check if this is a new user by checking if the user was just created
    _isNewUser = _user?.metadata.creationTime == _user?.metadata.lastSignInTime;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _isNewUser = false;
    notifyListeners();
  }

  // Reset new user flag (call after onboarding is complete)
  void resetNewUserFlag() {
    _isNewUser = false;
    notifyListeners();
  }
}