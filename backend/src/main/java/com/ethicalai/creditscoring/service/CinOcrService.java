package com.ethicalai.creditscoring.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

/**
 * Service for calling ML OCR service to extract CIN information
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CinOcrService {
    
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @Value("${app.ml-service.url:http://localhost:8000}")
    private String mlServiceUrl;
    
    /**
     * Extract CIN information from image using ML OCR service
     *
     * @param photo CIN photo file
     * @return Extracted CIN number
     * @throws Exception if OCR fails or CIN not found
     */
    public String extractCinFromImage(MultipartFile photo) throws Exception {
        log.info("🔵 Calling ML OCR service to extract CIN - File: {}, Size: {} bytes", 
                photo.getOriginalFilename(), photo.getSize());
        
        try {
            // Prepare multipart request
            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new ByteArrayResource(photo.getBytes()) {
                @Override
                public String getFilename() {
                    return photo.getOriginalFilename();
                }
            });
            body.add("enhance", "true");
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);
            
            HttpEntity<MultiValueMap<String, Object>> requestEntity = 
                new HttpEntity<>(body, headers);
            
            // Call ML OCR service
            String url = mlServiceUrl + "/ocr/cin";
            log.info("📤 Sending request to ML OCR: {}", url);
            
            ResponseEntity<String> response = restTemplate.postForEntity(
                url,
                requestEntity,
                String.class
            );
            
            if (response.getStatusCode().is2xxSuccessful()) {
                // Parse response
                JsonNode jsonResponse = objectMapper.readTree(response.getBody());
                
                boolean success = jsonResponse.path("success").asBoolean();
                if (!success) {
                    String message = jsonResponse.path("message").asText("OCR failed");
                    log.error("❌ ML OCR failed: {}", message);
                    throw new RuntimeException("OCR extraction failed: " + message);
                }
                
                // Extract CIN number from response
                String cinNumber = jsonResponse.path("data").path("cin_number").asText();
                double confidence = jsonResponse.path("data").path("confidence").asDouble(0.0);
                
                if (cinNumber == null || cinNumber.isEmpty()) {
                    log.error("❌ CIN number not found in OCR response");
                    throw new RuntimeException("CIN number not found in the image");
                }
                
                log.info("✅ CIN extracted successfully - Number: {}, Confidence: {}", 
                        cinNumber, confidence);
                
                // Check confidence threshold
                if (confidence < 0.5) {
                    log.warn("⚠️ Low OCR confidence: {} - CIN might be incorrect", confidence);
                }
                
                return cinNumber;
                
            } else {
                log.error("❌ ML OCR service returned error: {}", response.getStatusCode());
                throw new RuntimeException("ML OCR service error: " + response.getStatusCode());
            }
            
        } catch (Exception e) {
            log.error("❌ Failed to extract CIN from image: {}", e.getMessage(), e);
            throw new Exception("Failed to extract CIN information: " + e.getMessage(), e);
        }
    }
    
    /**
     * Verify CIN image against expected CIN number
     *
     * @param photo CIN photo file
     * @param expectedCin Expected CIN number
     * @return true if CIN matches, false otherwise
     * @throws Exception if verification fails
     */
    public boolean verifyCin(MultipartFile photo, String expectedCin) throws Exception {
        log.info("🔍 Verifying CIN image against expected: {}", expectedCin);
        
        try {
            // Extract CIN from image
            String extractedCin = extractCinFromImage(photo);
            
            // Compare with expected CIN (case-insensitive, ignore spaces)
            String normalizedExpected = expectedCin.toUpperCase().replaceAll("\\s+", "");
            String normalizedExtracted = extractedCin.toUpperCase().replaceAll("\\s+", "");
            
            boolean matches = normalizedExpected.equals(normalizedExtracted);
            
            if (matches) {
                log.info("✅ CIN verification successful - Match confirmed");
            } else {
                log.warn("⚠️ CIN mismatch - Expected: {}, Extracted: {}", 
                        normalizedExpected, normalizedExtracted);
            }
            
            return matches;
            
        } catch (Exception e) {
            log.error("❌ CIN verification failed: {}", e.getMessage());
            throw e;
        }
    }
    
    /**
     * Check if ML OCR service is available
     *
     * @return true if service is healthy
     */
    public boolean isOcrServiceAvailable() {
        try {
            String url = mlServiceUrl + "/health";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            boolean available = response.getStatusCode().is2xxSuccessful();
            
            if (available) {
                log.info("✅ ML OCR service is available");
            } else {
                log.warn("⚠️ ML OCR service health check failed");
            }
            
            return available;
            
        } catch (Exception e) {
            log.error("❌ ML OCR service is not available: {}", e.getMessage());
            return false;
        }
    }
}
