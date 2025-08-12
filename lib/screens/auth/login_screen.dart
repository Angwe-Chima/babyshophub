// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _googleLogin(BuildContext context) async {
    setState(() => _isGoogleLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).loginWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.neutralColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Nursery Room Illustration
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Center(
                  child: Icon(
                    Icons.child_care,
                    size: 100,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Welcome Text
              Text(
                'Welcome to',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondary,
                ),
              ),
              Text(
                'BabyShopHub!',
                style: AppConstants.headingLarge.copyWith(
                  color: AppConstants.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your one-stop shop for all things baby.',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacingExtraLarge),

              // Email Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address',
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'your@example.com',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Password Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '•••••••',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                    obscureText: true,
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Log In',
                    style: AppConstants.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: AppConstants.bodyMedium.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppConstants.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: Text(
                        'or',
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppConstants.borderColor)),
                  ],
                ),
              ),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : () => _googleLogin(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppConstants.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  icon: _isGoogleLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(
                    Icons.g_mobiledata,
                    color: AppConstants.textPrimary,
                    size: 24,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}