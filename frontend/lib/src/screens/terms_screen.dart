import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Terms of Service screen
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content: 'By accessing and using this service, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              context,
              title: '2. Use of Service',
              content: 'You agree to use our service for lawful purposes only and in accordance with these terms.',
            ),
            _buildSection(
              context,
              title: '3. Account Responsibilities',
              content: 'You are responsible for maintaining the confidentiality of your account and password.',
            ),
            _buildSection(
              context,
              title: '4. Credit Scoring',
              content: 'Our credit scoring is based on AI algorithms. While we strive for accuracy, scores are estimates and may not reflect your actual creditworthiness.',
            ),
            _buildSection(
              context,
              title: '5. Limitation of Liability',
              content: 'We shall not be liable for any indirect, incidental, special, consequential or punitive damages.',
            ),
            _buildSection(
              context,
              title: '6. Changes to Terms',
              content: 'We reserve the right to modify these terms at any time. Your continued use constitutes acceptance of changes.',
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
