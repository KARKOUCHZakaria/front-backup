import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/responsive_builder.dart';

/// Splash screen shown on app launch - Fully responsive for mobile, tablet, and desktop
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Navigate to onboarding after splash
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1212),
              Color(0xFF1A3A35),
              Color(0xFF2A5F7F),
            ],
          ),
        ),
        child: ResponsiveBuilder(
          builder: (context, deviceType, constraints) {
            // Responsive sizes based on device type
            final logoSize = ResponsiveValue<double>(
              mobile: 100,
              tablet: 140,
              desktop: 160,
            ).getValue(deviceType);

            final iconSize = ResponsiveValue<double>(
              mobile: 50,
              tablet: 70,
              desktop: 80,
            ).getValue(deviceType);

            final headlineSize = ResponsiveValue<double>(
              mobile: 32,
              tablet: 40,
              desktop: 48,
            ).getValue(deviceType);

            final subtitleSize = ResponsiveValue<double>(
              mobile: 18,
              tablet: 22,
              desktop: 26,
            ).getValue(deviceType);

            return Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo with responsive size
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.primaryCyan,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              size: iconSize,
                              color: AppColors.primaryCyan,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App name with responsive text
                          Text(
                            'Ethical AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: headlineSize,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Credit Scoring',
                            style: TextStyle(
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              fontSize: subtitleSize,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Loading indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
