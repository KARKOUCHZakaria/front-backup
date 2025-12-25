package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import com.ethicalai.creditscoring.dto.CreditApplicationDTO;
import com.ethicalai.creditscoring.dto.FairnessMetricsDTO;
import com.ethicalai.creditscoring.service.MLService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * ML Prediction Controller
 */
@Slf4j
@RestController
@RequestMapping("/api/ml")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class MLController {
    
    private final MLService mlService;
    
    @PostMapping("/explain")
    public ResponseEntity<ApiResponse<Map<String, Double>>> getShapExplanation(
            @RequestBody CreditApplicationDTO applicationDTO) {
        log.info("🔵 SHAP EXPLANATION REQUEST - Income: {}, Credit: {}", 
                applicationDTO.getAmtIncomeTotal(), applicationDTO.getAmtCredit());
        try {
            Map<String, Double> shapValues = mlService.getShapExplanation(applicationDTO);
            log.info("✅ SHAP explanation computed - {} features", shapValues.size());
            return ResponseEntity.ok(ApiResponse.success("SHAP values computed successfully", shapValues));
        } catch (Exception e) {
            log.error("❌ SHAP COMPUTATION FAILED - Error: {}", e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("SHAP_COMPUTATION_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/fairness")
    public ResponseEntity<ApiResponse<FairnessMetricsDTO>> getFairnessMetrics(
            @RequestParam(defaultValue = "CODE_GENDER") String protectedAttribute) {
        log.info("🔵 FAIRNESS METRICS REQUEST - Protected Attribute: {}", protectedAttribute);
        try {
            FairnessMetricsDTO metrics = mlService.getFairnessMetrics(protectedAttribute);
            log.info("✅ Fairness metrics computed - Attribute: {}", protectedAttribute);
            return ResponseEntity.ok(ApiResponse.success("Fairness metrics computed successfully", metrics));
        } catch (Exception e) {
            log.error("❌ FAIRNESS COMPUTATION FAILED - Attribute: {}, Error: {}", 
                    protectedAttribute, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("FAIRNESS_COMPUTATION_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Boolean>> checkHealth() {
        log.info("🔵 ML HEALTH CHECK");
        try {
            boolean healthy = mlService.checkModelHealth();
            log.info("✅ ML service status: {}", healthy ? "healthy" : "unhealthy");
            return ResponseEntity.ok(ApiResponse.success("ML service is " + (healthy ? "healthy" : "unhealthy"), healthy));
        } catch (Exception e) {
            log.error("❌ ML HEALTH CHECK FAILED - Error: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.success("ML service health check failed", false));
        }
    }
}
