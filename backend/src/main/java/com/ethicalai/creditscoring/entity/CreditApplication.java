package com.ethicalai.creditscoring.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Credit Application entity matching frontend CreditApplicationData model
 */
@Entity
@Table(name = "credit_applications", indexes = {
    @Index(name = "idx_app_user_id", columnList = "user_id"),
    @Index(name = "idx_app_status", columnList = "status"),
    @Index(name = "idx_app_created_at", columnList = "created_at")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreditApplication {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    // Demographic Information
    @Column(name = "code_gender", length = 10)
    private String codeGender; // M, F, XNA
    
    @Column(name = "days_birth")
    private Integer daysBirth; // Negative age in days
    
    @Column(name = "name_education_type", length = 100)
    private String nameEducationType;
    
    @Column(name = "name_family_status", length = 100)
    private String nameFamilyStatus;
    
    @Column(name = "cnt_children")
    private Integer cntChildren;
    
    // Financial Information
    @Column(name = "amt_income_total", precision = 15, scale = 2)
    private BigDecimal amtIncomeTotal;
    
    @Column(name = "amt_credit", precision = 15, scale = 2)
    private BigDecimal amtCredit;
    
    @Column(name = "amt_annuity", precision = 15, scale = 2)
    private BigDecimal amtAnnuity;
    
    @Column(name = "amt_goods_price", precision = 15, scale = 2)
    private BigDecimal amtGoodsPrice;
    
    // Employment Information
    @Column(name = "days_employed")
    private Integer daysEmployed;
    
    @Column(name = "occupation_type", length = 100)
    private String occupationType;
    
    @Column(name = "organization_type", length = 100)
    private String organizationType;
    
    // Contract Information
    @Column(name = "name_contract_type", length = 50)
    private String nameContractType;
    
    @Column(name = "name_income_type", length = 100)
    private String nameIncomeType;
    
    @Column(name = "name_housing_type", length = 100)
    private String nameHousingType;
    
    // Additional Features
    @Column(name = "flag_own_car", length = 1)
    private String flagOwnCar; // Y or N
    
    @Column(name = "flag_own_realty", length = 1)
    private String flagOwnRealty; // Y or N
    
    @Column(name = "region_rating_client")
    private Integer regionRatingClient;
    
    @Column(name = "ext_source_1", precision = 10, scale = 6)
    private BigDecimal extSource1;
    
    @Column(name = "ext_source_2", precision = 10, scale = 6)
    private BigDecimal extSource2;
    
    @Column(name = "ext_source_3", precision = 10, scale = 6)
    private BigDecimal extSource3;
    
    // Application Status
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ApplicationStatus status = ApplicationStatus.PENDING;
    
    @Column(name = "application_number", unique = true, length = 50)
    private String applicationNumber;
    
    @Column(name = "credit_score")
    private Integer creditScore; // ML-calculated credit score (300-850)
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;
    
    @Column(name = "processed_at")
    private LocalDateTime processedAt;
    
    public enum ApplicationStatus {
        DRAFT,
        PENDING,
        PROCESSING,
        APPROVED,
        REJECTED,
        UNDER_REVIEW,
        CANCELLED
    }
}
