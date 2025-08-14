// ======================= widgets/loading_indicator.dart =======================
import 'package:flutter/material.dart';
import '../config/constants.dart';

class LoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final bool showLogo;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 100.0,
    this.showLogo = true,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showLogo) ...[
              // Animated logo container
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animation.value * 0.1), // Subtle pulse effect
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: AppConstants.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(widget.size / 2),
                        child: Image.network(
                          'https://res.cloudinary.com/dpcgk2sev/image/upload/v1755112706/Image_fx_the_one_19_cgyeu0.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.baby_changing_station,
                                color: AppConstants.primaryColor,
                                size: widget.size * 0.6,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppConstants.spacingLarge),
            ],

            // Loading spinner
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
                backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              ),
            ),

            if (widget.message != null) ...[
              SizedBox(height: AppConstants.spacingLarge),
              Text(
                widget.message!,
                style: AppConstants.bodyLarge.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: AppConstants.spacingMedium),

            // App name with fade animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.7 + (_animation.value * 0.3),
                  child: Text(
                    'BabyShop',
                    style: AppConstants.headingMedium.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simple loading indicator without logo for inline use
class SimpleLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const SimpleLoadingIndicator({
    super.key,
    this.message,
    this.size = 30.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppConstants.primaryColor,
              ),
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              message!,
              style: AppConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}