package com.ethicalai.creditscoring.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Fairness Metrics DTO matching frontend FairnessMetrics model
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FairnessMetricsDTO {
    
    @JsonProperty("demographic_parity")
    private BigDecimal demographicParity;
    
    @JsonProperty("equal_opportunity")
    private BigDecimal equalOpportunity;
    
    @JsonProperty("disparate_impact")
    private BigDecimal disparateImpact;
    
    @JsonProperty("average_odds_difference")
    private BigDecimal averageOddsDifference;
    
    @JsonProperty("fairness_score")
    private Integer fairnessScore;
}
