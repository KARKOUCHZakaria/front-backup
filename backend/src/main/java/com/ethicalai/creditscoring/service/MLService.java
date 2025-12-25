package com.ethicalai.creditscoring.service;

import com.ethicalai.creditscoring.dto.CreditApplicationDTO;
import com.ethicalai.creditscoring.dto.FairnessMetricsDTO;
import com.ethicalai.creditscoring.dto.PredictionResultDTO;
import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.entity.PredictionResult;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.repository.PredictionResultRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.core.io.ByteArrayResource;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * ML Service for communicating with Python ML API
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MLService {
    
    private final PredictionResultRepository predictionResultRepository;
    private final WebClient.Builder webClientBuilder;
    
    @Value("${app.ml-service.url}")
    private String mlServiceUrl;
    
    @Transactional
    public PredictionResult predictCreditScore(CreditApplication application, CreditApplicationDTO dto) {
        long startTime = System.currentTimeMillis();
        
        try {
            // Call ML API
            WebClient webClient = webClientBuilder.baseUrl(mlServiceUrl).build();
            
            PredictionResultDTO mlResponse = webClient.post()
                    .uri("/predict")
                    .bodyValue(dto)
                    .retrieve()
                    .bodyToMono(PredictionResultDTO.class)
                    .timeout(Duration.ofSeconds(30))
                    .block();
            
            if (mlResponse == null) {
                throw new RuntimeException("ML Service returned null response");
            }
            
            long processingTime = System.currentTimeMillis() - startTime;
            
            // Save prediction result
            PredictionResult result = PredictionResult.builder()
                    .application(application)
                    .user(application.getUser())
                    .applicationIdRef(mlResponse.getApplicationId())
                    .predictionProbability(mlResponse.getPredictionProbability())
                    .creditScore(mlResponse.getCreditScore())
                    .decision(mlResponse.getDecision())
                    .confidence(mlResponse.getConfidence())
                    .shapValues(mlResponse.getShapValues())
                    .riskLevel(mlResponse.getRiskLevel())
                    .processingTimeMs(processingTime)
                    .build();
            
            // Add fairness metrics if available
            if (mlResponse.getFairnessMetrics() != null) {
                FairnessMetricsDTO metrics = mlResponse.getFairnessMetrics();
                result.setDemographicParity(metrics.getDemographicParity());
                result.setEqualOpportunity(metrics.getEqualOpportunity());
                result.setDisparateImpact(metrics.getDisparateImpact());
                result.setAverageOddsDifference(metrics.getAverageOddsDifference());
                result.setFairnessScore(metrics.getFairnessScore());
            }
            
            return predictionResultRepository.save(result);
            
        } catch (Exception e) {
            log.error("Error calling ML service", e);
            throw new RuntimeException("Failed to get prediction from ML service: " + e.getMessage());
        }
    }
    
    public Map<String, Double> getShapExplanation(CreditApplicationDTO dto) {
        try {
            WebClient webClient = webClientBuilder.baseUrl(mlServiceUrl).build();
            
            JsonNode response = webClient.post()
                    .uri("/explain")
                    .bodyValue(dto)
                    .retrieve()
                    .bodyToMono(JsonNode.class)
                    .timeout(Duration.ofSeconds(30))
                    .block();
            
            if (response == null) {
                return new HashMap<>();
            }
            
            Map<String, Double> shapValues = new HashMap<>();
            response.fields().forEachRemaining(entry -> {
                shapValues.put(entry.getKey(), entry.getValue().asDouble());
            });
            
            return shapValues;
            
        } catch (Exception e) {
            log.error("Error getting SHAP explanation", e);
            return new HashMap<>();
        }
    }
    
    public FairnessMetricsDTO getFairnessMetrics(String protectedAttribute) {
        try {
            WebClient webClient = webClientBuilder.baseUrl(mlServiceUrl).build();
            
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/fairness")
                            .queryParam("protected_attribute", protectedAttribute)
                            .build())
                    .retrieve()
                    .bodyToMono(FairnessMetricsDTO.class)
                    .timeout(Duration.ofSeconds(30))
                    .block();
            
        } catch (Exception e) {
            log.error("Error getting fairness metrics", e);
            return null;
        }
    }
    
    public boolean checkModelHealth() {
        try {
            WebClient webClient = webClientBuilder.baseUrl(mlServiceUrl).build();
            
            JsonNode response = webClient.get()
                    .uri("/health")
                    .retrieve()
                    .bodyToMono(JsonNode.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();
            
            return response != null && response.has("healthy") && response.get("healthy").asBoolean();
            
        } catch (Exception e) {
            log.error("Error checking ML model health", e);
            return false;
        }
    }
    
    public Map<String, Object> analyzeDocuments(
            Long applicationId,
            MultipartFile cinFront,  // nullable - auto-approved
            MultipartFile cinBack,   // nullable - auto-approved
            MultipartFile payslip1,
            MultipartFile payslip2,
            MultipartFile payslip3,
            MultipartFile taxDeclaration,
            MultipartFile bankStatement) {
        
        log.info("🤖 Analyzing documents for Application ID: {} (CIN auto-approved)", applicationId);
        
        try {
            WebClient webClient = webClientBuilder.baseUrl(mlServiceUrl).build();
            
            // CIN auto-approved at 95%
            Double cinScore = 95.0;
            log.info("✅ CIN Score: {} (auto-approved)", cinScore);
            
            // Analyze payslips (average of 3)
            Double payslip1Score = analyzeDocument(webClient, payslip1, "PAY_SLIP");
            Double payslip2Score = analyzeDocument(webClient, payslip2, "PAY_SLIP");
            Double payslip3Score = analyzeDocument(webClient, payslip3, "PAY_SLIP");
            Double payslipScore = (payslip1Score + payslip2Score + payslip3Score) / 3.0;
            log.info("✅ PaySlip Scores: {}, {}, {} -> Avg: {}", 
                    payslip1Score, payslip2Score, payslip3Score, payslipScore);
            
            // Analyze tax declaration
            Double taxScore = analyzeDocument(webClient, taxDeclaration, "TAX_DECLARATION");
            log.info("✅ Tax Score: {}", taxScore);
            
            // Analyze bank statement
            Double bankScore = analyzeDocument(webClient, bankStatement, "BANK_STATEMENT");
            log.info("✅ Bank Score: {}", bankScore);
            
            // Calculate average score
            Double averageScore = (cinScore + payslipScore + taxScore + bankScore) / 4.0;
            log.info("✅ Average Score: {}", averageScore);
            
            Map<String, Object> results = new HashMap<>();
            results.put("applicationId", applicationId);
            results.put("cinScore", cinScore);
            results.put("payslipScore", payslipScore);
            results.put("taxScore", taxScore);
            results.put("bankScore", bankScore);
            results.put("averageScore", averageScore);
            results.put("timestamp", LocalDateTime.now().toString());
            
            // Save results to JSON file
            saveResultsToJson(results);
            
            return results;
            
        } catch (Exception e) {
            log.error("❌ Error analyzing documents", e);
            throw new RuntimeException("Failed to analyze documents: " + e.getMessage());
        }
    }
    
    private Double analyzeDocument(WebClient webClient, MultipartFile file, String documentType) {
        try {
            MultipartBodyBuilder builder = new MultipartBodyBuilder();
            builder.part("file", new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename();
                }
            });
            builder.part("document_type", documentType);
            
            // Use unified analyze/document endpoint
            Map response = webClient.post()
                    .uri("/analyze/document")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .bodyValue(builder.build())
                    .retrieve()
                    .bodyToMono(Map.class)
                    .timeout(Duration.ofSeconds(60))
                    .block();
            
            if (response != null && response.containsKey("score")) {
                Object scoreObj = response.get("score");
                if (scoreObj instanceof Number) {
                    return ((Number) scoreObj).doubleValue();
                }
            }
            
            log.warn("⚠️ No score returned for {} - using default 50.0", documentType);
            return 50.0; // Default score if ML service fails
            
        } catch (Exception e) {
            log.error("❌ Error analyzing {} document", documentType, e);
            return 50.0; // Default score on error
        }
    }
    
    public PredictionResultDTO toPredictionResultDTO(PredictionResult result) {
        FairnessMetricsDTO fairnessMetrics = null;
        
        if (result.getDemographicParity() != null) {
            fairnessMetrics = FairnessMetricsDTO.builder()
                    .demographicParity(result.getDemographicParity())
                    .equalOpportunity(result.getEqualOpportunity())
                    .disparateImpact(result.getDisparateImpact())
                    .averageOddsDifference(result.getAverageOddsDifference())
                    .fairnessScore(result.getFairnessScore())
                    .build();
        }
        
        return PredictionResultDTO.builder()
                .applicationId(result.getApplicationIdRef())
                .predictionProbability(result.getPredictionProbability())
                .creditScore(result.getCreditScore())
                .decision(result.getDecision())
                .confidence(result.getConfidence())
                .shapValues(result.getShapValues())
                .fairnessMetrics(fairnessMetrics)
                .timestamp(result.getTimestamp())
                .riskLevel(result.getRiskLevel())
                .build();
    }
    
    private void saveResultsToJson(Map<String, Object> results) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
            
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String filename = String.format("ml_result_%s_app_%s.json", 
                    timestamp, results.get("applicationId"));
            
            File outputDir = new File("ml/models/results");
            outputDir.mkdirs();
            
            File outputFile = new File(outputDir, filename);
            mapper.writeValue(outputFile, results);
            
            log.info("💾 ML results saved to: {}", outputFile.getAbsolutePath());
            
        } catch (IOException e) {
            log.error("⚠️ Failed to save ML results to file", e);
        }
    }
}
