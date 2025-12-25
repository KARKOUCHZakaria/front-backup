package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import com.ethicalai.creditscoring.dto.AuthRequest;
import com.ethicalai.creditscoring.dto.UserDTO;
import com.ethicalai.creditscoring.service.AuthService;
import com.ethicalai.creditscoring.service.CinOcrService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Authentication Controller
 */
@Slf4j
@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "User authentication and registration endpoints")
public class AuthController {
    
    private final AuthService authService;
    private final CinOcrService cinOcrService;
    
    @Value("${app.file-upload.identity-scan-directory}")
    private String identityScanDirectory;
    
    @Operation(summary = "Register new user", description = "Create a new user account with email, username and password")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "201", description = "User registered successfully", 
            content = @Content(schema = @Schema(implementation = UserDTO.class)))
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Invalid input or email already exists")
    @PostMapping("/register")
    public ResponseEntity<UserDTO> register(@Valid @RequestBody AuthRequest request) {
        log.info("🔵 REGISTER REQUEST - Email: {}, Username: {}", request.getEmail(), request.getUsername());
        try {
            UserDTO user = authService.register(request);
            log.info("✅ REGISTER SUCCESS - User ID: {}, Email: {}", user.getId(), user.getEmail());
            return ResponseEntity.status(HttpStatus.CREATED).body(user);
        } catch (Exception e) {
            log.error("❌ REGISTER FAILED - Error: {}", e.getMessage(), e);
            throw new RuntimeException("Registration failed: " + e.getMessage());
        }
    }
    
    @Operation(summary = "Login user", description = "Authenticate user with email and password, returns JWT token")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Login successful", 
            content = @Content(schema = @Schema(implementation = UserDTO.class)))
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "Invalid credentials")
    @PostMapping("/login")
    public ResponseEntity<UserDTO> login(@Valid @RequestBody AuthRequest request) {
        log.info("🔵 LOGIN REQUEST - Email: {}", request.getEmail());
        try {
            UserDTO user = authService.login(request);
            log.info("✅ LOGIN SUCCESS - User ID: {}, Email: {}", user.getId(), user.getEmail());
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            log.error("❌ LOGIN FAILED - Email: {}, Error: {}", request.getEmail(), e.getMessage());
            throw new RuntimeException("Login failed: " + e.getMessage());
        }
    }
    
    @PostMapping("/verify-cin")
    public ResponseEntity<ApiResponse<UserDTO>> verifyCin(
            @RequestParam Long userId,
            @RequestParam String cin,
            @RequestParam(required = false) MultipartFile cinPhoto) {
        log.info("🔵 VERIFY CIN REQUEST - User ID: {}, CIN: {}", userId, cin);
        try {
            String cinPhotoPath = null;
            
            if (cinPhoto != null && !cinPhoto.isEmpty()) {
                log.info("📸 Processing CIN photo - Original filename: {}, Size: {} bytes", 
                        cinPhoto.getOriginalFilename(), cinPhoto.getSize());
                
                // Check if ML OCR service is available
                boolean ocrAvailable = cinOcrService.isOcrServiceAvailable();
                
                if (ocrAvailable) {
                    // Use ML OCR to verify CIN from image
                    log.info("🤖 Using ML OCR to verify CIN from image");
                    boolean cinMatches = cinOcrService.verifyCin(cinPhoto, cin);
                    
                    if (!cinMatches) {
                        log.error("❌ CIN verification failed - Image does not match provided CIN");
                        return ResponseEntity.badRequest()
                                .body(ApiResponse.error("CIN_MISMATCH", 
                                        "The CIN in the uploaded image does not match the provided CIN number"));
                    }
                    log.info("✅ ML OCR verification successful - CIN matches");
                } else {
                    log.warn("⚠️ ML OCR service not available - Skipping automatic verification");
                }
                
                // Save the verified CIN photo
                cinPhotoPath = saveIdentityScan(cinPhoto, userId, cin);
                log.info("✅ CIN photo saved - Path: {}", cinPhotoPath);
            }
            
            UserDTO user = authService.verifyCin(userId, cin, cinPhotoPath);
            log.info("✅ CIN VERIFICATION SUCCESS - User ID: {}", userId);
            return ResponseEntity.ok(ApiResponse.success("CIN verified successfully", user));
        } catch (Exception e) {
            log.error("❌ CIN VERIFICATION FAILED - User ID: {}, Error: {}", userId, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("CIN_VERIFICATION_FAILED", e.getMessage()));
        }
    }
    
    private String saveIdentityScan(MultipartFile file, Long userId, String cin) throws IOException {
        // Create identity scan directory if it doesn't exist
        File directory = new File(identityScanDirectory);
        if (!directory.exists()) {
            directory.mkdirs();
            log.info("📁 Created identity scan directory: {}", identityScanDirectory);
        }
        
        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : "";
        String filename = String.format("cin_%s_%s_%s%s", 
                userId, 
                cin, 
                UUID.randomUUID().toString().substring(0, 8),
                extension);
        
        Path filePath = Paths.get(identityScanDirectory, filename);
        
        // Save file
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        log.info("💾 Identity scan saved - Filename: {}, Path: {}", filename, filePath.toAbsolutePath());
        
        return filePath.toString();
    }
}

