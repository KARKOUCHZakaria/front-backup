import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ML API imports
import 'services/ml_api_service.dart';
import 'services/ai_service.dart';
import 'models/prediction_result.dart';

/// Simple models for the demo app.
class CreditApplication {
  final String id;
  final double amount;
  final DateTime date;
  final String status;

  CreditApplication({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class ShapValue {
  final String feature;
  final double value; // positive => supports approval, negative => opposes

  ShapValue(this.feature, this.value);
}

class ScoreResult {
  final int score; // 0-900
  final String status;
  final List<ShapValue> shapValues;

  ScoreResult({
    required this.score,
    required this.status,
    required this.shapValues,
  });
}

/// Dummy applications provider
final applicationsProvider =
    StateNotifierProvider<ApplicationsNotifier, List<CreditApplication>>(
      (ref) => ApplicationsNotifier(),
    );

class ApplicationsNotifier extends StateNotifier<List<CreditApplication>> {
  ApplicationsNotifier()
    : super(
        List.generate(
          6,
          (i) => CreditApplication(
            id: 'app-${i + 1}',
            amount: (1000 + i * 250).toDouble(),
            date: DateTime.now().subtract(Duration(days: i * 3)),
            status: i % 3 == 0
                ? 'Approved'
                : (i % 3 == 1 ? 'Pending' : 'Rejected'),
          ),
        ),
      );

  void add(CreditApplication app) {
    state = [app, ...state];
  }
}

/// Provider holding the latest score result
final latestScoreProvider = StateProvider<ScoreResult?>((ref) => null);

/// Theme mode provider to toggle light/dark from the UI
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// CTA variant provider: 0 = Variant A (neon-cyan), 1 = Variant B (warm-orange)
final ctaVariantProvider = StateProvider<int>((ref) => 0);

/// Simple function to compute a dummy score and SHAP values from a form map.
ScoreResult computeScoreFromForm(Map<String, dynamic> form) {
  final rnd = Random();
  // generate dummy SHAP values using some of the inputs
  final income = (form['income'] ?? 3000).toDouble();
  final debtRatio = (form['debtRatio'] ?? 0.3).toDouble();
  final age = (form['age'] ?? 30).toDouble();
  final loan = (form['loanAmount'] ?? 5000).toDouble();

  final incomeImpact = (income / 10000) * 200; // positive
  final debtImpact = (1 - debtRatio) * 200; // positive when low debt
  final ageImpact = ((age >= 25 && age <= 65) ? 100 : -50);
  final loanImpact = (loan < 10000 ? 50 : -100);

  final base = 400 + incomeImpact + debtImpact + ageImpact + loanImpact;
  final noise = rnd.nextInt(100) - 50;
  int score = base.round() + noise;
  score = score.clamp(0, 900);

  final shap = <ShapValue>[];
  shap.add(ShapValue('Income', (incomeImpact / 900) * 100));
  shap.add(ShapValue('Debt Ratio', (debtImpact / 900) * 100));
  shap.add(ShapValue('Age', (ageImpact / 900) * 100));
  shap.add(ShapValue('Loan Amount', (loanImpact / 900) * 100));
  shap.add(ShapValue('Random Model Noise', (noise / 900) * 100));

  final status = score > 500 ? 'Approved' : 'Rejected';

  return ScoreResult(score: score, status: status, shapValues: shap);
}

/// Helper to save a score result as a credit application
void saveScoreToHistory(WidgetRef ref, ScoreResult score, {double loanAmount = 5000}) {
  final app = CreditApplication(
    id: 'app-${DateTime.now().millisecondsSinceEpoch}',
    amount: loanAmount,
    date: DateTime.now(),
    status: score.status,
  );
  ref.read(applicationsProvider.notifier).add(app);
}

// ========== ML API Providers ==========

/// Provider for ML API Service (singleton)
final mlApiServiceProvider = Provider<MLApiService>((ref) {
  return MLApiService();
});

/// Provider for AI Service (singleton)
final aiServiceProvider = Provider<AIService>((ref) {
  final mlApiService = ref.watch(mlApiServiceProvider);
  // Set useMockData to true for testing without backend
  return AIService(mlApiService: mlApiService, useMockData: false);
});

/// Provider for model health status
final modelHealthProvider = FutureProvider<bool>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.checkModelHealth();
});

/// Provider for fairness metrics
final fairnessMetricsProvider = FutureProvider<FairnessMetrics?>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.getFairnessMetrics();
});

/// Provider for feature importance
final featureImportanceProvider = FutureProvider<Map<String, double>>((ref) async {
  final mlApiService = ref.watch(mlApiServiceProvider);
  try {
    return await mlApiService.getFeatureImportance();
  } catch (e) {
    debugPrint('Failed to get feature importance: $e');
    return {};
  }
});

/// Provider for current prediction state
final currentPredictionProvider = StateProvider<PredictionResult?>((ref) => null);

/// Provider to track if using mock data
final useMockDataProvider = StateProvider<bool>((ref) => false);
