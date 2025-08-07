// ======================= app.dart =======================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      home: auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}