package com.ethicalai.creditscoring.service;

import com.ethicalai.creditscoring.dto.CreditApplicationDTO;
import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.repository.CreditApplicationRepository;
import com.ethicalai.creditscoring.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Credit Application Service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CreditApplicationService {
    
    private final CreditApplicationRepository applicationRepository;
    private final UserRepository userRepository;
    
    @Transactional
    public CreditApplication createApplication(Long userId, CreditApplicationDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        CreditApplication application = CreditApplication.builder()
                .user(user)
                .applicationNumber(generateApplicationNumber())
                .codeGender(dto.getCodeGender())
                .daysBirth(dto.getDaysBirth())
                .nameEducationType(dto.getNameEducationType())
                .nameFamilyStatus(dto.getNameFamilyStatus())
                .cntChildren(dto.getCntChildren())
                .amtIncomeTotal(dto.getAmtIncomeTotal())
                .amtCredit(dto.getAmtCredit())
                .amtAnnuity(dto.getAmtAnnuity())
                .amtGoodsPrice(dto.getAmtGoodsPrice())
                .daysEmployed(dto.getDaysEmployed())
                .occupationType(dto.getOccupationType())
                .organizationType(dto.getOrganizationType())
                .nameContractType(dto.getNameContractType())
                .nameIncomeType(dto.getNameIncomeType())
                .nameHousingType(dto.getNameHousingType())
                .flagOwnCar(dto.getFlagOwnCar())
                .flagOwnRealty(dto.getFlagOwnRealty())
                .regionRatingClient(dto.getRegionRatingClient())
                .extSource1(dto.getExtSource1())
                .extSource2(dto.getExtSource2())
                .extSource3(dto.getExtSource3())
                .status(CreditApplication.ApplicationStatus.PENDING)
                .submittedAt(LocalDateTime.now())
                .build();
        
        return applicationRepository.save(application);
    }
    
    public List<CreditApplication> getUserApplications(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return applicationRepository.findByUserOrderByCreatedAtDesc(user);
    }
    
    public CreditApplication getApplicationById(Long applicationId) {
        return applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));
    }
    
    @Transactional
    public CreditApplication updateApplicationStatus(Long applicationId, CreditApplication.ApplicationStatus status) {
        CreditApplication application = getApplicationById(applicationId);
        application.setStatus(status);
        
        if (status == CreditApplication.ApplicationStatus.APPROVED || 
            status == CreditApplication.ApplicationStatus.REJECTED) {
            application.setProcessedAt(LocalDateTime.now());
        }
        
        return applicationRepository.save(application);
    }
    
    public CreditApplication saveApplication(CreditApplication application) {
        return applicationRepository.save(application);
    }
    
    private String generateApplicationNumber() {
        return "APP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    public CreditApplicationDTO toDTO(CreditApplication application) {
        return CreditApplicationDTO.builder()
                .id(application.getId())
                .userId(application.getUser().getId())
                .codeGender(application.getCodeGender())
                .daysBirth(application.getDaysBirth())
                .nameEducationType(application.getNameEducationType())
                .nameFamilyStatus(application.getNameFamilyStatus())
                .cntChildren(application.getCntChildren())
                .amtIncomeTotal(application.getAmtIncomeTotal())
                .amtCredit(application.getAmtCredit())
                .amtAnnuity(application.getAmtAnnuity())
                .amtGoodsPrice(application.getAmtGoodsPrice())
                .daysEmployed(application.getDaysEmployed())
                .occupationType(application.getOccupationType())
                .organizationType(application.getOrganizationType())
                .nameContractType(application.getNameContractType())
                .nameIncomeType(application.getNameIncomeType())
                .nameHousingType(application.getNameHousingType())
                .flagOwnCar(application.getFlagOwnCar())
                .flagOwnRealty(application.getFlagOwnRealty())
                .regionRatingClient(application.getRegionRatingClient())
                .extSource1(application.getExtSource1())
                .extSource2(application.getExtSource2())
                .extSource3(application.getExtSource3())
                .applicationNumber(application.getApplicationNumber())
                .creditScore(application.getCreditScore())
                .status(application.getStatus().name())
                .createdAt(application.getCreatedAt() != null ? application.getCreatedAt().toString() : null)
                .updatedAt(application.getUpdatedAt() != null ? application.getUpdatedAt().toString() : null)
                .submittedAt(application.getSubmittedAt() != null ? application.getSubmittedAt().toString() : null)
                .processedAt(application.getProcessedAt() != null ? application.getProcessedAt().toString() : null)
                .build();
    }
}
