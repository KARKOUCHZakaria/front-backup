import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_builder.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      {
        'title': 'Ethical AI Credit Scoring',
        'subtitle': 'We use transparent, unbiased AI to build a credit score that truly reflects your financial health.',
        'asset': 'assets/lottie/onboarding1.json',
        'gradient': [const Color(0xFF0A1212), const Color(0xFF1A3A35)],
      },
      {
        'title': 'Explainable Decisions',
        'subtitle': 'Understand exactly how your credit score is calculated with transparent, AI-driven insights.',
        'asset': 'assets/lottie/onboarding2.json',
        'gradient': [const Color(0xFF0D2B2B), const Color(0xFF1B3F34)],
      },
      {
        'title': 'Fair Credit Scoring',
        'subtitle': 'Powered by transparent AI to build a credit score that truly reflects you.',
        'asset': 'assets/lottie/onboarding3.json',
        'gradient': [const Color(0xFF4B7C8F), const Color(0xFF2A5F7F)],
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final p = pages[index];
                  return _buildStyledPage(
                    title: p['title'] as String,
                    subtitle: p['subtitle'] as String,
                    asset: p['asset'] as String,
                    gradient: p['gradient'] as List<Color>,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _currentPage == i ? 36 : 12,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? AppColors.primaryCyan
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage == pages.length - 1) {
                              context.go('/login');
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.ease,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCyan.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledPage({
    required String title,
    required String subtitle,
    required String asset,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ResponsiveBuilder(
        builder: (context, deviceType, constraints) {
          final horizontalPadding = ResponsiveValue<double>(
            mobile: 20.0,
            tablet: 48.0,
            desktop: 80.0,
          ).getValue(deviceType);

          final lottieWidth = ResponsiveValue<double>(
            mobile: constraints.maxWidth * 0.7,
            tablet: constraints.maxWidth * 0.5,
            desktop: constraints.maxWidth * 0.4,
          ).getValue(deviceType);

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Lottie.asset(
                        asset,
                        repeat: true,
                        width: lottieWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildGlassCard(title: title, subtitle: subtitle, deviceType: deviceType),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassCard({required String title, required String subtitle, required DeviceType deviceType}) {
    final titleSize = ResponsiveValue<double>(
      mobile: 28,
      tablet: 32,
      desktop: 36,
    ).getValue(deviceType);

    final subtitleSize = ResponsiveValue<double>(
      mobile: 15,
      tablet: 17,
      desktop: 19,
    ).getValue(deviceType);

    final cardPadding = ResponsiveValue<double>(
      mobile: 24,
      tablet: 32,
      desktop: 40,
    ).getValue(deviceType);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: deviceType == DeviceType.desktop ? 800 : double.infinity,
          ),
          padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding + 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFFB0C4C4),
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
