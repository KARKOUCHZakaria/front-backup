package com.ethicalai.creditscoring.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Credit Application Data DTO matching frontend CreditApplicationData model
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreditApplicationDTO {
    
    // Demographic Information
    @JsonProperty("CODE_GENDER")
    private String codeGender;
    
    @JsonProperty("DAYS_BIRTH")
    private Integer daysBirth;
    
    @JsonProperty("NAME_EDUCATION_TYPE")
    private String nameEducationType;
    
    @JsonProperty("NAME_FAMILY_STATUS")
    private String nameFamilyStatus;
    
    @JsonProperty("CNT_CHILDREN")
    private Integer cntChildren;
    
    // Financial Information
    @JsonProperty("AMT_INCOME_TOTAL")
    private BigDecimal amtIncomeTotal;
    
    @JsonProperty("AMT_CREDIT")
    private BigDecimal amtCredit;
    
    @JsonProperty("AMT_ANNUITY")
    private BigDecimal amtAnnuity;
    
    @JsonProperty("AMT_GOODS_PRICE")
    private BigDecimal amtGoodsPrice;
    
    // Employment Information
    @JsonProperty("DAYS_EMPLOYED")
    private Integer daysEmployed;
    
    @JsonProperty("OCCUPATION_TYPE")
    private String occupationType;
    
    @JsonProperty("ORGANIZATION_TYPE")
    private String organizationType;
    
    // Contract Information
    @JsonProperty("NAME_CONTRACT_TYPE")
    private String nameContractType;
    
    @JsonProperty("NAME_INCOME_TYPE")
    private String nameIncomeType;
    
    @JsonProperty("NAME_HOUSING_TYPE")
    private String nameHousingType;
    
    // Additional Features
    @JsonProperty("FLAG_OWN_CAR")
    private String flagOwnCar;
    
    @JsonProperty("FLAG_OWN_REALTY")
    private String flagOwnRealty;
    
    @JsonProperty("REGION_RATING_CLIENT")
    private Integer regionRatingClient;
    
    @JsonProperty("EXT_SOURCE_1")
    private BigDecimal extSource1;
    
    @JsonProperty("EXT_SOURCE_2")
    private BigDecimal extSource2;
    
    @JsonProperty("EXT_SOURCE_3")
    private BigDecimal extSource3;
    
    // Application metadata
    private Long id;
    private Long userId;
    private String applicationNumber;
    private Integer creditScore;
    private String status;
    private String createdAt;
    private String updatedAt;
    private String submittedAt;
    private String processedAt;
}
