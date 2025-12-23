import 'package:json_annotation/json_annotation.dart';

part 'prediction_result.g.dart';

/// Model representing the ML prediction result from the backend
@JsonSerializable()
class PredictionResult {
  /// Application ID
  @JsonKey(name: 'application_id')
  final String? applicationId;
  
  /// Prediction probability (0-1, where closer to 1 means higher default risk)
  @JsonKey(name: 'prediction_probability')
  final double predictionProbability;
  
  /// Credit score (0-900, where higher is better)
  @JsonKey(name: 'credit_score')
  final int creditScore;
  
  /// Decision: 'approved' or 'rejected'
  final String decision;
  
  /// Confidence level (0-1)
  final double confidence;
  
  /// SHAP values for feature importance
  @JsonKey(name: 'shap_values')
  final Map<String, double>? shapValues;
  
  /// Fairness metrics
  @JsonKey(name: 'fairness_metrics')
  final FairnessMetrics? fairnessMetrics;
  
  /// Timestamp of prediction
  final DateTime? timestamp;
  
  /// Risk level: 'low', 'medium', 'high'
  @JsonKey(name: 'risk_level')
  final String? riskLevel;

  PredictionResult({
    this.applicationId,
    required this.predictionProbability,
    required this.creditScore,
    required this.decision,
    required this.confidence,
    this.shapValues,
    this.fairnessMetrics,
    this.timestamp,
    this.riskLevel,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);

  /// Get risk level based on credit score
  String getRiskLevel() {
    if (riskLevel != null) return riskLevel!;
    
    if (creditScore >= 700) return 'low';
    if (creditScore >= 500) return 'medium';
    return 'high';
  }

  /// Get approval status as boolean
  bool get isApproved => decision.toLowerCase() == 'approved';

  /// Get top contributing features from SHAP values
  List<MapEntry<String, double>> getTopFeatures({int count = 5}) {
    if (shapValues == null) return [];
    
    final sorted = shapValues!.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    
    return sorted.take(count).toList();
  }
}

/// Model representing fairness metrics for the prediction
@JsonSerializable()
class FairnessMetrics {
  /// Demographic parity difference (closer to 0 is better)
  @JsonKey(name: 'demographic_parity')
  final double? demographicParity;
  
  /// Equal opportunity difference (closer to 0 is better)
  @JsonKey(name: 'equal_opportunity')
  final double? equalOpportunity;
  
  /// Disparate impact ratio (closer to 1 is better)
  @JsonKey(name: 'disparate_impact')
  final double? disparateImpact;
  
  /// Average odds difference (closer to 0 is better)
  @JsonKey(name: 'average_odds_difference')
  final double? averageOddsDifference;
  
  /// Fairness score (0-100, where 100 is perfectly fair)
  @JsonKey(name: 'fairness_score')
  final double? fairnessScore;
  
  /// Protected attribute analyzed (e.g., 'gender', 'age_group')
  @JsonKey(name: 'protected_attribute')
  final String? protectedAttribute;

  FairnessMetrics({
    this.demographicParity,
    this.equalOpportunity,
    this.disparateImpact,
    this.averageOddsDifference,
    this.fairnessScore,
    this.protectedAttribute,
  });

  factory FairnessMetrics.fromJson(Map<String, dynamic> json) =>
      _$FairnessMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$FairnessMetricsToJson(this);

  /// Check if the prediction meets fairness thresholds
  bool isFair({
    double demographicParityThreshold = 0.1,
    double equalOpportunityThreshold = 0.1,
    double disparateImpactMin = 0.8,
    double disparateImpactMax = 1.25,
  }) {
    if (demographicParity != null &&
        demographicParity!.abs() > demographicParityThreshold) {
      return false;
    }
    
    if (equalOpportunity != null &&
        equalOpportunity!.abs() > equalOpportunityThreshold) {
      return false;
    }
    
    if (disparateImpact != null &&
        (disparateImpact! < disparateImpactMin ||
            disparateImpact! > disparateImpactMax)) {
      return false;
    }
    
    return true;
  }
}
