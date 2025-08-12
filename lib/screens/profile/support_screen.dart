// screens/profile/support_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I track my order?',
      answer: 'You can track your order by going to Order History in your profile or using the order number sent to your email.',
    ),
    FAQItem(
      question: 'What is your return policy?',
      answer: 'We offer a 30-day return policy for unused items in original packaging. Contact support to initiate a return.',
    ),
    FAQItem(
      question: 'How can I change my shipping address?',
      answer: 'You can update your shipping address in the Saved Addresses section of your profile before placing an order.',
    ),
    FAQItem(
      question: 'Do you offer gift wrapping?',
      answer: 'Yes! We offer gift wrapping services for an additional fee. You can select this option during checkout.',
    ),
    FAQItem(
      question: 'Are your products organic?',
      answer: 'Many of our products are organic and certified. Look for the organic label on product pages for verification.',
    ),
    FAQItem(
      question: 'How do I apply a discount code?',
      answer: 'Enter your discount code in the promo code field during checkout before completing your purchase.',
    ),
    FAQItem(
      question: 'What payment methods do you accept?',
      answer: 'We accept all major credit cards, PayPal, Apple Pay, Google Pay, and bank transfers.',
    ),
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      queryParameters: {
        'subject': 'Support Request',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+12345678900',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    // Here you would typically send the feedback to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback submitted successfully!'),
        backgroundColor: AppConstants.successColor,
      ),
    );

    _feedbackController.clear();
  }

  Widget _buildContactSupportCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Support',
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),

          // Live Chat Support
          _buildContactItem(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat Support',
            subtitle: 'Connect instantly with a support agent for quick help',
            color: AppConstants.accentColor,
            onTap: () {
              // Implement live chat functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live chat feature coming soon!')),
              );
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Email Support
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Send us a detailed message and we\'ll get back to you within 24 hours',
            color: AppConstants.primaryColor,
            onTap: _launchEmail,
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Call Us
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: 'Available Monday-Friday: 9AM-6PM Business Hours. Call (123) 456-7890',
            color: AppConstants.successColor,
            onTap: _launchPhone,
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Submit Feedback
          _buildContactItem(
            icon: Icons.feedback_outlined,
            title: 'Submit Feedback',
            subtitle: 'Share your thoughts and suggestions to help us improve',
            color: Color(0xFF6C5CE7),
            onTap: () {
              // Scroll to feedback section
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Us Your Feedback',
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Message',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type your message or suggestion here...',
              hintStyle: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondary.withOpacity(0.6),
              ),
              filled: true,
              fillColor: AppConstants.neutralColor.withOpacity(0.3),
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
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                elevation: 2,
              ),
              child: Text(
                'Send Feedback',
                style: AppConstants.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ...(_faqItems.map((faq) => _buildFAQItem(faq)).toList()),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        faq.question,
        style: AppConstants.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: AppConstants.spacingMedium,
          ),
          child: Text(
            faq.answer,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        title: const Text(
          'Support',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSupportCard(),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildFeedbackSection(),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildFAQSection(),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
