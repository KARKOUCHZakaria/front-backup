// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) =>
    PredictionResult(
      applicationId: json['application_id'] as String?,
      predictionProbability: (json['prediction_probability'] as num).toDouble(),
      creditScore: (json['credit_score'] as num).toInt(),
      decision: json['decision'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      shapValues: (json['shap_values'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      fairnessMetrics: json['fairness_metrics'] == null
          ? null
          : FairnessMetrics.fromJson(
              json['fairness_metrics'] as Map<String, dynamic>,
            ),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      riskLevel: json['risk_level'] as String?,
    );

Map<String, dynamic> _$PredictionResultToJson(PredictionResult instance) =>
    <String, dynamic>{
      'application_id': instance.applicationId,
      'prediction_probability': instance.predictionProbability,
      'credit_score': instance.creditScore,
      'decision': instance.decision,
      'confidence': instance.confidence,
      'shap_values': instance.shapValues,
      'fairness_metrics': instance.fairnessMetrics,
      'timestamp': instance.timestamp?.toIso8601String(),
      'risk_level': instance.riskLevel,
    };

FairnessMetrics _$FairnessMetricsFromJson(Map<String, dynamic> json) =>
    FairnessMetrics(
      demographicParity: (json['demographic_parity'] as num?)?.toDouble(),
      equalOpportunity: (json['equal_opportunity'] as num?)?.toDouble(),
      disparateImpact: (json['disparate_impact'] as num?)?.toDouble(),
      averageOddsDifference: (json['average_odds_difference'] as num?)
          ?.toDouble(),
      fairnessScore: (json['fairness_score'] as num?)?.toDouble(),
      protectedAttribute: json['protected_attribute'] as String?,
    );

Map<String, dynamic> _$FairnessMetricsToJson(FairnessMetrics instance) =>
    <String, dynamic>{
      'demographic_parity': instance.demographicParity,
      'equal_opportunity': instance.equalOpportunity,
      'disparate_impact': instance.disparateImpact,
      'average_odds_difference': instance.averageOddsDifference,
      'fairness_score': instance.fairnessScore,
      'protected_attribute': instance.protectedAttribute,
    };
