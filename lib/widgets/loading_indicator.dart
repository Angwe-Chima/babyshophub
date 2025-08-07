// ======================= widgets/loading_indicator.dart =======================
import 'package:flutter/material.dart';
import '../config/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 50.0,
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
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
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