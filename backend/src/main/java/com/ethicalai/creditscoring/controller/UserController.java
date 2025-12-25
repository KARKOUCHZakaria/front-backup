package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import com.ethicalai.creditscoring.dto.UserDTO;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

/**
 * User Controller - Handles user profile and account management
 */
@Slf4j
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User profile and account management endpoints")
public class UserController {
    
    private final UserRepository userRepository;
    
    @Operation(
        summary = "Get current user profile", 
        description = "Returns the authenticated user's profile information including all details",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @io.swagger.v3.oas.annotations.responses.ApiResponse(
        responseCode = "200", 
        description = "User profile retrieved successfully", 
        content = @Content(schema = @Schema(implementation = UserDTO.class))
    )
    @io.swagger.v3.oas.annotations.responses.ApiResponse(
        responseCode = "401", 
        description = "Unauthorized - Invalid or missing JWT token"
    )
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDTO>> getCurrentUser() {
        log.info("🔵 GET CURRENT USER REQUEST");
        
        try {
            // Get authenticated user email from security context
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();
            log.info("🔹 Fetching user data for email: {}", email);
            
            // Find user in database
            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            log.info("✅ User found - ID: {}, Username: {}, Email: {}", 
                    user.getId(), user.getUsername(), user.getEmail());
            
            // Convert to DTO with all fields
            UserDTO userDTO = UserDTO.builder()
                    .id(user.getId())
                    .email(user.getEmail())
                    .username(user.getUsername())
                    .identityVerified(user.getIdentityVerified())
                    .cin(user.getCin())
                    .cinPhoto(user.getCinPhoto())
                    .phone(user.getPhone())
                    .countryCode(user.getCountryCode())
                    .build();
            
            log.info("✅ GET CURRENT USER SUCCESS - User ID: {}, Verified: {}", 
                    user.getId(), user.getIdentityVerified());
            
            return ResponseEntity.ok(ApiResponse.success("User profile retrieved", userDTO));
            
        } catch (Exception e) {
            log.error("❌ GET CURRENT USER FAILED - Error: {}", e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("FETCH_USER_FAILED", e.getMessage()));
        }
    }
}
