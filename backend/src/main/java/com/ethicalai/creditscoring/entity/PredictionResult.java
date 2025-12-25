package com.ethicalai.creditscoring.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * Prediction Result entity matching frontend PredictionResult model
 */
@Entity
@Table(name = "prediction_results", indexes = {
    @Index(name = "idx_pred_application_id", columnList = "application_id"),
    @Index(name = "idx_pred_user_id", columnList = "user_id"),
    @Index(name = "idx_pred_decision", columnList = "decision")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PredictionResult {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "application_id", nullable = false)
    private CreditApplication application;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "application_id_ref", unique = true, length = 100)
    private String applicationIdRef;
    
    @Column(name = "prediction_probability", nullable = false, precision = 10, scale = 6)
    private BigDecimal predictionProbability;
    
    @Column(name = "credit_score", nullable = false)
    private Integer creditScore;
    
    @Column(nullable = false, length = 20)
    private String decision; // approved, rejected
    
    @Column(nullable = false, precision = 10, scale = 6)
    private BigDecimal confidence;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "shap_values", columnDefinition = "jsonb")
    private Map<String, Double> shapValues;
    
    @Column(name = "risk_level", length = 20)
    private String riskLevel; // low, medium, high
    
    // Fairness Metrics
    @Column(name = "demographic_parity", precision = 10, scale = 6)
    private BigDecimal demographicParity;
    
    @Column(name = "equal_opportunity", precision = 10, scale = 6)
    private BigDecimal equalOpportunity;
    
    @Column(name = "disparate_impact", precision = 10, scale = 6)
    private BigDecimal disparateImpact;
    
    @Column(name = "average_odds_difference", precision = 10, scale = 6)
    private BigDecimal averageOddsDifference;
    
    @Column(name = "fairness_score")
    private Integer fairnessScore;
    
    @Column(name = "model_version", length = 50)
    private String modelVersion;
    
    @Column(name = "processing_time_ms")
    private Long processingTimeMs;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> metadata;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime timestamp;
}
