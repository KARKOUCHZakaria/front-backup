import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_button.dart';

class ExplainableOnboardingScreen extends StatelessWidget {
  const ExplainableOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF071213), Color(0xFF1A3B2F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _ProgressDot(active: false),
                  SizedBox(width: 8),
                  _ProgressDot(active: true),
                  SizedBox(width: 8),
                  _ProgressDot(active: false),
                ],
              ),
              const SizedBox(height: 20),

              // Illustration placeholder (1:1 square)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.06 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'Illustration',
                        style: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Glass card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explainable Decisions',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Understand exactly how your credit score is calculated with transparent, AI-driven insights.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: GradientButton(
                  label: 'Get Started',
                  onPressed: () => context.go('/login'),
                  borderRadius: 40,
                  colors: const [Color(0xFF1DF6CE), Color(0xFF21E6D0)],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool active;
  const _ProgressDot({required this.active});

  @override
  Widget build(BuildContext context) => Container(
    width: active ? 40 : 36,
    height: 8,
    decoration: BoxDecoration(
      color: active
          ? const Color(0xFF23F6D9)
          : Colors.white.withAlpha((0.18 * 255).round()),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.04 * 255).round()),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withAlpha((0.04 * 255).round()),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
