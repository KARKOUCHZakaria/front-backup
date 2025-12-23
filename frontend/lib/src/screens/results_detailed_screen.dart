import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/gradient_button.dart';
import '../providers.dart';

class ResultsDetailedScreen extends ConsumerWidget {
  const ResultsDetailedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(latestScoreProvider);
    final shap = score?.shapValues ?? [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071213), Color(0xFF133B2F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Detailed Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.white.withAlpha((0.03 * 255).round()),
                        padding: const EdgeInsets.all(12),
                        child: shap.isEmpty
                            ? const Center(
                                child: Text(
                                  'No detailed breakdown available.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.separated(
                                itemCount: shap.length,
                                separatorBuilder: (context, i) =>
                                    const Divider(color: Colors.white10),
                                itemBuilder: (context, i) {
                                  final s = shap[i];
                                  // convert to a -1..1 magnitude for bar length
                                  final magnitude =
                                      (s.value).clamp(-100.0, 100.0) / 100.0;
                                  final color = s.value >= 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent;
                                  final label = s.feature;
                                  final percent = (s.value).abs();

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 5,
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.white.withAlpha(
                                                    (0.04 * 255).round(),
                                                  ),
                                                ),
                                              ),
                                              // Animate the bar length from 0 -> target using TweenAnimationBuilder
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: TweenAnimationBuilder<double>(
                                                  tween: Tween(
                                                    begin: 0.0,
                                                    end: magnitude.abs(),
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 700,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  builder:
                                                      (
                                                        context,
                                                        value,
                                                        child,
                                                      ) => FractionallySizedBox(
                                                        widthFactor: value
                                                            .clamp(0.0, 1.0),
                                                        child: Container(
                                                          height: 22,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            color: color
                                                                .withAlpha(
                                                                  (0.9 * 255)
                                                                      .round(),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 56,
                                          child: Text(
                                            '${percent.toStringAsFixed(1)}%',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Back to Home',
                  onPressed: () => context.go('/user/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
