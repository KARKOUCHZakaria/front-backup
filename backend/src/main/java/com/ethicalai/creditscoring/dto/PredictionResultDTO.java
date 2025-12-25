package com.ethicalai.creditscoring.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * Prediction Result DTO matching frontend PredictionResult model
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PredictionResultDTO {
    
    @JsonProperty("application_id")
    private String applicationId;
    
    @JsonProperty("prediction_probability")
    private BigDecimal predictionProbability;
    
    @JsonProperty("credit_score")
    private Integer creditScore;
    
    private String decision;
    
    private BigDecimal confidence;
    
    @JsonProperty("shap_values")
    private Map<String, Double> shapValues;
    
    @JsonProperty("fairness_metrics")
    private FairnessMetricsDTO fairnessMetrics;
    
    private LocalDateTime timestamp;
    
    @JsonProperty("risk_level")
    private String riskLevel;
}
