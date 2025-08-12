// ======================= providers/auth_provider.dart =======================
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isNewUser = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
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
    // Check if this is a new user by comparing creation and last sign-in times
    _isNewUser = _user?.metadata.creationTime == _user?.metadata.lastSignInTime;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _isNewUser = false;
    notifyListeners();
  }

  void resetNewUserFlag() {
    _isNewUser = false;
    notifyListeners();
  }
}
