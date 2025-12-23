import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/score_gauge.dart';
import '../widgets/shap_bar.dart';
import '../widgets/shap_bar_chart.dart';
import '../widgets/status_badge.dart';

class ScoreResultScreen extends ConsumerWidget {
  const ScoreResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(latestScoreProvider);
    if (result == null) {
      return Scaffold(body: Center(child: Text('No score available.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Score Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ScoreGaugeWidget(score: result.score, size: 160),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Decision',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            StatusBadge(status: result.status),
                            const SizedBox(height: 12),
                            Text(
                              'Score: ${result.score}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Why this decision?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // SHAP chart summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        ShapBarChartWidget(
                          features: result.shapValues
                              .map((s) => s.feature)
                              .toList(),
                          values: result.shapValues
                              .map((s) => s.value)
                              .toList(),
                          maxValue:
                              result.shapValues
                                  .map((s) => s.value.abs())
                                  .fold<double>(0, (p, e) => e > p ? e : p) *
                              1.2,
                        ),
                        const SizedBox(height: 8),
                        const Text('Top contributing features (visual)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...result.shapValues.map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ShapBarWidget(feature: s.feature, value: s.value),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommendations',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '- Increase your income or reduce debt ratio to improve score.',
                        ),
                        const Text('- Consider a shorter loan or co-signer.'),
                        const Text('- Check for errors in your credit report.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
