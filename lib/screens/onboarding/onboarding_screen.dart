// ======================= Updated onboarding_screen.dart =======================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../config/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Welcome to BabyShop",
      description: "Your one-stop destination for all baby essentials. From diapers to toys, we've got everything you need.",
      icon: Icons.baby_changing_station,
      color: AppConstants.primaryColor,
    ),
    OnboardingData(
      title: "Quality Products",
      description: "We offer only the highest quality products from trusted brands to keep your little one safe and happy.",
      icon: Icons.verified,
      color: AppConstants.successColor,
    ),
    OnboardingData(
      title: "Fast Delivery",
      description: "Get your baby essentials delivered quickly to your doorstep. Because we know you can't wait!",
      icon: Icons.local_shipping,
      color: AppConstants.accentColor,
    ),
    OnboardingData(
      title: "Personalized Experience",
      description: "Tell us your preferences and we'll show you the products that matter most to you!",
      icon: Icons.favorite,
      color: AppConstants.warmAccent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Check if user exists and has valid data
      if (userProvider.currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User data not found. Please try logging in again.'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
        return;
      }

      // Mark onboarding as completed - this will trigger navigation in WrapperScreen
      await userProvider.markOnboardingCompleted();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      child: Image.network(
                        'https://res.cloudinary.com/dpcgk2sev/image/upload/v1755112706/Image_fx_the_one_19_cgyeu0.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                            ),
                            child: Icon(
                              Icons.baby_changing_station,
                              color: AppConstants.primaryColor,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Skip button
                  TextButton(
                    onPressed: _isLoading ? null : _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _isLoading ? AppConstants.textLight : AppConstants.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page view content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingExtraLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: data.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: data.color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            size: 70,
                            color: data.color,
                          ),
                        ),
                        SizedBox(height: AppConstants.spacingLarge * 2),
                        // Title with fade animation
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: 1.0,
                          child: Text(
                            data.title,
                            style: AppConstants.headingLarge.copyWith(
                              fontSize: 32,
                              color: AppConstants.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: AppConstants.spacingLarge),
                        // Description with fade animation
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: 1.0,
                          child: Text(
                            data.description,
                            style: AppConstants.bodyLarge.copyWith(
                              color: AppConstants.textSecondary,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section with indicators and button
            Container(
              color: AppConstants.cardColor,
              padding: const EdgeInsets.all(AppConstants.paddingExtraLarge),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppConstants.primaryColor
                              : AppConstants.borderColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingExtraLarge),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppConstants.borderColor,
                        shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                      ).copyWith(
                        elevation: MaterialStateProperty.all(_isLoading ? 0 : 4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Choose Your Interests'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}