// ======================= screens/wrapper_screen.dart =======================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart' as auth;
import '../../providers/user_provider.dart';
import '../../providers/product_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/category_selection_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/loading_indicator.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({Key? key}) : super(key: key);

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  bool _isCheckingUser = false;

  Future<void> _checkUserStatus(User user, UserProvider userProvider, auth.AuthProvider authProvider) async {
    if (_isCheckingUser) return;

    setState(() {
      _isCheckingUser = true;
    });

    try {
      final userExists = await userProvider.checkUserExists(user.uid);

      if (!userExists) {
        // Create new user document
        await userProvider.createUser(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );
      } else {
        // Load existing user data
        await userProvider.loadUser(user.uid);
      }
    } catch (e) {
      debugPrint('Error checking user status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUser = false;
        });
      }
    }
  }

  Widget _getScreenForUserState(User? user, UserProvider userProvider, auth.AuthProvider authProvider) {
    // Not authenticated - show login
    if (user == null) {
      return const LoginScreen();
    }

    // Still checking user status or loading
    if (_isCheckingUser || userProvider.isLoading) {
      return const LoadingIndicator(
        message: 'Setting up your account...',
      );
    }

    final currentUser = userProvider.currentUser;

    // User document doesn't exist (shouldn't happen but handle it)
    if (currentUser == null) {
      return const OnboardingScreen();
    }

    // NEW USER FLOW: Show onboarding for new users who haven't completed it
    if (authProvider.isNewUser && !currentUser.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // EXISTING USER FLOW: Check if user has completed everything
    if (!currentUser.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // User completed onboarding but hasn't selected interests
    if (currentUser.interests.isEmpty) {
      return const CategorySelectionScreen();
    }

    // User is fully set up - initialize products and go to home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.initialize(userInterests: currentUser.interests);
    });

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<auth.AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, child) {
        final user = authProvider.user;

        // Check user status when user logs in and we don't have user data
        if (user != null && userProvider.currentUser == null && !_isCheckingUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkUserStatus(user, userProvider, authProvider);
          });
        }

        // Clear user data when logged out
        if (user == null && userProvider.currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.clearUser();
            authProvider.resetNewUserFlag();
          });
        }

        return _getScreenForUserState(user, userProvider, authProvider);
      },
    );
  }
}