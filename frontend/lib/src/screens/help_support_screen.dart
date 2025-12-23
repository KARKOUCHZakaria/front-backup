import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: 'Search for help...', hintStyle: TextStyle(color: AppColors.textMuted), border: InputBorder.none, icon: Icon(Icons.search, color: AppColors.primaryCyan)),
                ),
              ),
              const SizedBox(height: 32),
              Text('QUICK ACTIONS', style: TextStyle(color: AppColors.primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildQuickActionCard(context, Icons.chat, 'Live Chat', 'Chat with us', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening chat...'))))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildQuickActionCard(context, Icons.email, 'Email Us', 'Send email', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email client...'))))),
                ],
              ),
              const SizedBox(height: 32),
              Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(color: AppColors.primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildFAQSection(context),
              const SizedBox(height: 32),
              Text('CONTACT INFORMATION', style: TextStyle(color: AppColors.primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildContactCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primaryCyan, size: 32)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {'question': 'How is my credit score calculated?', 'answer': 'Your credit score is calculated using AI algorithms that analyze your financial history, payment patterns, and other relevant factors.'},
      {'question': 'How long does application processing take?', 'answer': 'Most applications are processed within 24-48 hours. You\'ll receive a notification once your application is reviewed.'},
      {'question': 'Can I update my information?', 'answer': 'Yes, you can update your personal information anytime from your profile screen.'},
      {'question': 'Is my data secure?', 'answer': 'We use industry-standard encryption and security measures to protect your data. Read our privacy policy for more details.'},
    ];

    return Container(
      decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: faqs.map((faq) => _buildFAQItem(context, faq)).toList()),
    );
  }

  Widget _buildFAQItem(BuildContext context, Map<String, String> faq) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(faq['question']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      iconColor: AppColors.primaryCyan,
      collapsedIconColor: AppColors.textMuted,
      children: [Text(faq['answer']!, style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5))],
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildContactRow(Icons.email, 'Email', 'support@ethicalai.com'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone, 'Phone', '+1 (555) 123-4567'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.access_time, 'Hours', 'Mon-Fri, 9AM-6PM EST'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primaryCyan, size: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
