import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart' as auth;
import '../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/category_selection_screen.dart';
import '../../screens/home/home_screen.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({Key? key}) : super(key: key);

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  bool _isInitialized = false;
  bool _isCheckingUser = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _checkUserStatus(User user, UserProvider userProvider, auth.AuthProvider authProvider) async {
    if (_isCheckingUser) return;

    setState(() {
      _isCheckingUser = true;
    });

    try {
      final userExists = await userProvider.checkUserExists(user.uid);

      if (!userExists) {
        // New user - create document without completing onboarding
        await userProvider.createUser(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );
      } else {
        // Existing user - load their data
        await userProvider.loadUser(user.uid);
      }

      if (authProvider.isNewUser) {
        authProvider.resetNewUserFlag();
      }
    } catch (e) {
      debugPrint('Error checking user status: $e');
    } finally {
      setState(() {
        _isCheckingUser = false;
      });
    }
  }

  Widget _getScreenForUserState(User? user, UserProvider userProvider, auth.AuthProvider authProvider) {
    // Not authenticated
    if (user == null) {
      return const LoginScreen();
    }

    // Still checking user status or loading
    if (_isCheckingUser || userProvider.isLoading) {
      return const LoadingScreen();
    }

    final currentUser = userProvider.currentUser;

    // User document doesn't exist - shouldn't happen but handle it
    if (currentUser == null) {
      return const OnboardingScreen();
    }

    // Check onboarding completion status
    if (!currentUser.hasCompletedOnboarding) {
      // Show onboarding if user hasn't seen it
      return const OnboardingScreen();
    }

    // Check if user has selected interests but not completed onboarding
    if (currentUser.interests.isEmpty) {
      return const CategorySelectionScreen();
    }

    // User is fully set up - go to home
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const LoadingScreen();
    }

    return Consumer2<auth.AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        final user = authProvider.user;

        // Check user status when user changes and we don't have user data
        if (user != null && userProvider.currentUser == null && !_isCheckingUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkUserStatus(user, userProvider, authProvider);
          });
        }

        // Clear user data when logged out
        if (user == null && userProvider.currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.clearUser();
          });
        }

        return _getScreenForUserState(user, userProvider, authProvider);
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.baby_changing_station,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}