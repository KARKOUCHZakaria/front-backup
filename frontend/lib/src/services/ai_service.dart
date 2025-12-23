import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers.dart';
import '../models/credit_application_data.dart';
import '../models/prediction_result.dart';
import 'ml_api_service.dart';

class AIService {
  final MLApiService _mlApiService;
  final bool _useMockData;

  AIService({
    MLApiService? mlApiService,
    bool useMockData = false,
  })  : _mlApiService = mlApiService ?? MLApiService(),
        _useMockData = useMockData;

  /// Predict credit score from form data
  /// If [useMockData] is true or API fails, falls back to mock data
  Future<ScoreResult> predict(Map<String, dynamic> features) async {
    if (_useMockData) {
      return _getMockPrediction(features);
    }

    try {
      // Convert form data to CreditApplicationData
      final applicationData = _convertFormToApplicationData(features);
      
      // Call ML API
      final prediction = await _mlApiService.predict(applicationData);
      
      // Convert PredictionResult to ScoreResult
      return _convertPredictionToScoreResult(prediction);
    } catch (e) {
      // Fallback to mock data if API fails
      debugPrint('API prediction failed, using mock data: $e');
      return _getMockPrediction(features);
    }
  }

  /// Get SHAP explanation values
  Future<List<ShapValue>> explain(Map<String, dynamic> features) async {
    if (_useMockData) {
      return _getMockShapValues();
    }

    try {
      // Convert form data to CreditApplicationData
      final applicationData = _convertFormToApplicationData(features);
      
      // Get SHAP values from API
      final shapMap = await _mlApiService.explainShap(applicationData);
      
      // Convert to ShapValue list
      return shapMap.entries
          .map((entry) => ShapValue(entry.key, entry.value))
          .toList();
    } catch (e) {
      // Fallback to mock data if API fails
      debugPrint('API SHAP explanation failed, using mock data: $e');
      return _getMockShapValues();
    }
  }

  /// Get fairness metrics
  Future<FairnessMetrics?> getFairnessMetrics({
    String protectedAttribute = 'CODE_GENDER',
  }) async {
    if (_useMockData) {
      return null;
    }

    try {
      return await _mlApiService.getFairnessMetrics(
        protectedAttribute: protectedAttribute,
      );
    } catch (e) {
      debugPrint('Failed to get fairness metrics: $e');
      return null;
    }
  }

  /// Check if ML model is healthy
  Future<bool> checkModelHealth() async {
    if (_useMockData) {
      return true;
    }

    try {
      final health = await _mlApiService.checkModelHealth();
      return health.healthy;
    } catch (e) {
      debugPrint('Model health check failed: $e');
      return false;
    }
  }

  /// Convert form data to CreditApplicationData
  CreditApplicationData _convertFormToApplicationData(
    Map<String, dynamic> form,
  ) {
    return CreditApplicationData.fromForm(
      gender: form['gender'] ?? 'Male',
      age: (form['age'] ?? 30).toInt(),
      income: (form['income'] ?? 50000).toDouble(),
      loanAmount: (form['loanAmount'] ?? 10000).toDouble(),
      annuity: (form['annuity'] ?? (form['loanAmount'] ?? 10000) / 12).toDouble(),
      education: form['education'] ?? 'Secondary / secondary special',
      familyStatus: form['familyStatus'] ?? 'Married',
      children: (form['children'] ?? 0).toInt(),
      employmentYears: (form['employmentYears'] ?? 5).toInt(),
      occupation: form['occupation'] ?? 'Laborers',
      contractType: form['contractType'] ?? 'Cash loans',
      incomeType: form['incomeType'] ?? 'Working',
      housingType: form['housingType'] ?? 'House / apartment',
      ownCar: form['ownCar'] ?? false,
      ownRealty: form['ownRealty'] ?? false,
    );
  }

  /// Convert PredictionResult to ScoreResult
  ScoreResult _convertPredictionToScoreResult(PredictionResult prediction) {
    // Convert SHAP values from map to list
    final shapValues = prediction.shapValues?.entries
            .map((entry) => ShapValue(entry.key, entry.value))
            .toList() ??
        [];

    return ScoreResult(
      score: prediction.creditScore,
      status: prediction.decision,
      shapValues: shapValues,
    );
  }

  /// Mock prediction for fallback
  Future<ScoreResult> _getMockPrediction(Map<String, dynamic> features) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return computeScoreFromForm(features);
  }

  /// Mock SHAP values for fallback
  Future<List<ShapValue>> _getMockShapValues() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      ShapValue('AMT_INCOME_TOTAL', 0.25),
      ShapValue('AMT_CREDIT', -0.18),
      ShapValue('DAYS_BIRTH', 0.05),
      ShapValue('DAYS_EMPLOYED', -0.08),
    ];
  }
}
