
// ======================= app.dart =======================
import 'package:flutter/material.dart';
import 'screens/onboarding/wrapper_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/category_selection_screen.dart';
import 'screens/home/home_screen.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      home: const WrapperScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/category-selection': (context) => const CategorySelectionScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}