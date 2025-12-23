import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Privacy Policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: December 11, 2025',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us, including your name, email address, financial information, and other personal data necessary for credit scoring.',
            ),
            _buildSection(
              context,
              title: '2. How We Use Your Information',
              content: 'We use the information we collect to provide, maintain, and improve our services, including calculating your credit score using AI algorithms.',
            ),
            _buildSection(
              context,
              title: '3. Data Security',
              content: 'We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure, alteration, and destruction.',
            ),
            _buildSection(
              context,
              title: '4. AI and Machine Learning',
              content: 'Our AI algorithms are designed to be fair, transparent, and unbiased. We regularly audit our systems to ensure ethical practices.',
            ),
            _buildSection(
              context,
              title: '5. Your Rights',
              content: 'You have the right to access, correct, or delete your personal information. You can also request a copy of your data at any time.',
            ),
            _buildSection(
              context,
              title: '6. Contact Us',
              content: 'If you have any questions about this Privacy Policy, please contact us at privacy@ethicalai.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
