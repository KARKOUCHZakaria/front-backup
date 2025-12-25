package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import com.ethicalai.creditscoring.dto.CreditApplicationDTO;
import com.ethicalai.creditscoring.dto.PredictionResultDTO;
import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.entity.PredictionResult;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.entity.Document;
import com.ethicalai.creditscoring.repository.UserRepository;
import com.ethicalai.creditscoring.service.CreditApplicationService;
import com.ethicalai.creditscoring.service.MLService;
import com.ethicalai.creditscoring.service.DocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

/**
 * Credit Application Controller
 */
@Slf4j
@RestController
@RequestMapping("/api/applications")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class ApplicationController {
    
    private final CreditApplicationService applicationService;
    private final MLService mlService;
    private final UserRepository userRepository;
    private final DocumentService documentService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<PredictionResultDTO>> submitApplication(
            @RequestBody CreditApplicationDTO applicationDTO,
            Authentication authentication) {
        log.info("🔵 SUBMIT APPLICATION REQUEST - User: {}", authentication.getName());
        try {
            // Get authenticated user
            User user = userRepository.findByEmail(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            log.info("📝 Creating application for User ID: {}", user.getId());
            
            // Create application
            CreditApplication application = applicationService.createApplication(user.getId(), applicationDTO);
            log.info("✅ Application created - ID: {}, Number: {}", application.getId(), application.getApplicationNumber());
            
            // Get prediction from ML service
            log.info("🤖 Requesting ML prediction for Application ID: {}", application.getId());
            PredictionResult prediction = mlService.predictCreditScore(application, applicationDTO);
            log.info("✅ ML Prediction received - Decision: {}, Score: {}", 
                    prediction.getDecision(), prediction.getCreditScore());
            
            // Update application status based on prediction
            CreditApplication.ApplicationStatus status = prediction.getDecision().equalsIgnoreCase("approved")
                    ? CreditApplication.ApplicationStatus.APPROVED
                    : CreditApplication.ApplicationStatus.REJECTED;
            applicationService.updateApplicationStatus(application.getId(), status);
            log.info("✅ Application status updated - Status: {}", status);
            
            // Convert to DTO
            PredictionResultDTO resultDTO = mlService.toPredictionResultDTO(prediction);
            
            return ResponseEntity.ok(ApiResponse.success("Application submitted successfully", resultDTO));
            
        } catch (Exception e) {
            log.error("❌ APPLICATION SUBMISSION FAILED - User: {}, Error: {}", 
                    authentication.getName(), e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("APPLICATION_SUBMISSION_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<CreditApplicationDTO>>> getUserApplications(@PathVariable Long userId) {
        log.info("🔵 GET USER APPLICATIONS - User ID: {}", userId);
        try {
            List<CreditApplication> applications = applicationService.getUserApplications(userId);
            List<CreditApplicationDTO> dtos = applications.stream()
                    .map(applicationService::toDTO)
                    .collect(Collectors.toList());
            log.info("✅ Found {} applications for User ID: {}", dtos.size(), userId);
            
            return ResponseEntity.ok(ApiResponse.success(dtos));
        } catch (Exception e) {
            log.error("❌ FETCH APPLICATIONS FAILED - User ID: {}, Error: {}", 
                    userId, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("FETCH_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/{applicationId}")
    public ResponseEntity<ApiResponse<CreditApplicationDTO>> getApplication(@PathVariable Long applicationId) {
        log.info("🔵 GET APPLICATION - Application ID: {}", applicationId);
        try {
            CreditApplication application = applicationService.getApplicationById(applicationId);
            CreditApplicationDTO dto = applicationService.toDTO(application);
            log.info("✅ Application retrieved - ID: {}, Status: {}", 
                    applicationId, application.getStatus());
            
            return ResponseEntity.ok(ApiResponse.success(dto));
        } catch (Exception e) {
            log.error("❌ GET APPLICATION FAILED - Application ID: {}, Error: {}", 
                    applicationId, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("FETCH_FAILED", e.getMessage()));
        }
    }
    
    @PostMapping(value = "/upload-and-analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadAndAnalyze(
            @RequestParam("payslip1") MultipartFile payslip1,
            @RequestParam("payslip2") MultipartFile payslip2,
            @RequestParam("payslip3") MultipartFile payslip3,
            @RequestParam("taxDeclaration") MultipartFile taxDeclaration,
            @RequestParam("bankStatement") MultipartFile bankStatement,
            Authentication authentication) {
        
        log.info("🔵 UPLOAD AND ANALYZE - User: {}, Files: 5 (CIN auto-approved)", authentication.getName());
        
        try {
            // Get authenticated user
            User user = userRepository.findByEmail(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            log.info("📝 Processing documents for User ID: {}", user.getId());
            
            // Create a basic application first
            CreditApplicationDTO basicApp = CreditApplicationDTO.builder()
                    .amtCredit(BigDecimal.valueOf(10000.0)) // Default loan amount
                    .nameContractType("Cash loans")
                    .codeGender("M")
                    .flagOwnCar("N")
                    .flagOwnRealty("N")
                    .cntChildren(0)
                    .amtIncomeTotal(BigDecimal.valueOf(30000.0))
                    .nameIncomeType("Working")
                    .nameEducationType("Higher education")
                    .nameFamilyStatus("Single")
                    .nameHousingType("Rented apartment")
                    .daysEmployed(365)
                    .daysBirth(10950)
                    .build();
            
            CreditApplication application = applicationService.createApplication(user.getId(), basicApp);
            log.info("✅ Application created - ID: {}, Number: {}", application.getId(), application.getApplicationNumber());
            
            // Call ML service to analyze documents and get scores (CIN auto-approved at 95%)
            log.info("🤖 Sending documents to ML service for analysis");
            Map<String, Object> mlResults = mlService.analyzeDocuments(
                application.getId(),
                null,  // CIN front - auto-approved
                null,  // CIN back - auto-approved
                payslip1,
                payslip2,
                payslip3,
                taxDeclaration,
                bankStatement
            );
            
            // Extract scores (CIN automatically set to 95%)
            Double cinScore = 95.0;  // Auto-approved CIN score
            Double payslipScore = (Double) mlResults.get("payslipScore");
            Double taxScore = (Double) mlResults.get("taxScore");
            Double bankScore = (Double) mlResults.get("bankScore");
            Double averageScore = (Double) mlResults.get("averageScore");
            
            log.info("✅ ML Analysis complete - Avg Score: {}", averageScore);
            log.info("   CIN: {}, PaySlip: {}, Tax: {}, Bank: {}", 
                    cinScore, payslipScore, taxScore, bankScore);
            
            // Determine decision based on average score
            String decision = averageScore >= 70.0 ? "APPROVED" : "REJECTED";
            int creditScore = (int) (300 + (averageScore / 100.0 * 550)); // Scale to 300-850
            
            // Update application status and credit score
            CreditApplication.ApplicationStatus status = decision.equals("APPROVED")
                    ? CreditApplication.ApplicationStatus.APPROVED
                    : CreditApplication.ApplicationStatus.REJECTED;
            application.setCreditScore(creditScore);
            application.setStatus(status);
            applicationService.saveApplication(application);
            
            // Save documents to backend (skip CIN - auto-approved)
            log.info("💾 Saving documents to backend storage");
            documentService.uploadDocument(user.getId(), payslip1, Document.DocumentType.PAY_SLIP, application.getId());
            documentService.uploadDocument(user.getId(), payslip2, Document.DocumentType.PAY_SLIP, application.getId());
            documentService.uploadDocument(user.getId(), payslip3, Document.DocumentType.PAY_SLIP, application.getId());
            documentService.uploadDocument(user.getId(), taxDeclaration, Document.DocumentType.TAX_DECLARATION, application.getId());
            documentService.uploadDocument(user.getId(), bankStatement, Document.DocumentType.BANK_STATEMENT, application.getId());
            log.info("✅ All documents saved");
            
            // Prepare response
            Map<String, Object> response = new HashMap<>();
            response.put("applicationId", application.getId());
            response.put("applicationNumber", application.getApplicationNumber());
            response.put("creditScore", creditScore);
            response.put("decision", decision);
            response.put("status", status.name());
            response.put("message", "Application processed successfully");
            
            Map<String, Double> documentScores = new HashMap<>();
            documentScores.put("cinScore", cinScore);
            documentScores.put("payslipScore", payslipScore);
            documentScores.put("taxScore", taxScore);
            documentScores.put("bankScore", bankScore);
            response.put("documentScores", documentScores);
            
            log.info("✅ Application processed - ID: {}, Decision: {}, Score: {}", 
                    application.getId(), decision, creditScore);
            
            return ResponseEntity.ok(ApiResponse.success("Application processed successfully", response));
            
        } catch (Exception e) {
            log.error("❌ UPLOAD AND ANALYZE FAILED - User: {}, Error: {}", 
                    authentication.getName(), e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("UPLOAD_FAILED", e.getMessage()));
        }
    }
}
