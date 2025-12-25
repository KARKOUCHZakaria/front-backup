package com.ethicalai.creditscoring.service;

import com.ethicalai.creditscoring.dto.AuthRequest;
import com.ethicalai.creditscoring.dto.UserDTO;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.repository.UserRepository;
import com.ethicalai.creditscoring.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Authentication Service
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    
    @Transactional
    public UserDTO register(AuthRequest request) {
        log.info("🔹 [AuthService] Starting registration process for email: {}", request.getEmail());
        
        // Check if user already exists
        log.debug("🔹 [AuthService] Checking if user exists with email: {}", request.getEmail());
        if (userRepository.existsByEmail(request.getEmail())) {
            log.error("❌ [AuthService] Registration failed - Email already exists: {}", request.getEmail());
            throw new RuntimeException("Email already registered");
        }
        log.debug("✅ [AuthService] Email is available: {}", request.getEmail());
        
        // Create new user
        log.debug("🔹 [AuthService] Creating new user object...");
        User user = User.builder()
                .email(request.getEmail())
                .username(request.getUsername() != null ? request.getUsername() : request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .identityVerified(false)
                .isActive(true)
                .emailVerified(false)
                .role(User.UserRole.USER)
                .build();
        
        log.debug("🔹 [AuthService] Saving user to database...");
        user = userRepository.save(user);
        log.info("✅ [AuthService] User saved successfully - ID: {}, Email: {}", user.getId(), user.getEmail());
        
        // Generate JWT token
        log.debug("🔹 [AuthService] Generating JWT token...");
        String token = jwtUtil.generateToken(user.getEmail());
        log.info("✅ [AuthService] JWT token generated for user: {}", user.getEmail());
        
        // Convert to DTO
        log.debug("🔹 [AuthService] Converting user to DTO...");
        UserDTO userDTO = UserDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .identityVerified(user.getIdentityVerified())
                .token(token)
                .build();
        
        log.info("✅ [AuthService] Registration completed successfully for: {}", user.getEmail());
        return userDTO;
    }
    
    @Transactional
    public UserDTO login(AuthRequest request) {
        log.info("🔹 [AuthService] Starting login process for email: {}", request.getEmail());
        
        // Authenticate user
        log.debug("🔹 [AuthService] Authenticating user credentials...");
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        log.info("✅ [AuthService] User authenticated successfully: {}", request.getEmail());
        
        // Find user
        log.debug("🔹 [AuthService] Fetching user from database...");
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        log.debug("✅ [AuthService] User found - ID: {}, Username: {}", user.getId(), user.getUsername());
        
        // Update last login
        log.debug("🔹 [AuthService] Updating last login timestamp...");
        user.setLastLogin(LocalDateTime.now());
        user = userRepository.save(user);
        
        // Generate JWT token
        log.debug("🔹 [AuthService] Generating JWT token...");
        String token = jwtUtil.generateToken(user.getEmail());
        log.info("✅ [AuthService] JWT token generated for user: {}", user.getEmail());
        
        // Convert to DTO
        log.debug("🔹 [AuthService] Converting user to DTO...");
        UserDTO userDTO = UserDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .identityVerified(user.getIdentityVerified())
                .phone(user.getPhone())
                .countryCode(user.getCountryCode())
                .token(token)
                .build();
        
        log.info("✅ [AuthService] Login completed successfully for: {}", user.getEmail());
        return userDTO;
    }
    
    @Transactional
    public UserDTO verifyCin(Long userId, String cin, String cinPhotoPath) {
        log.info("🔹 [AuthService] Starting CIN verification for user ID: {}", userId);
        
        log.debug("🔹 [AuthService] Fetching user from database...");
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        log.debug("✅ [AuthService] User found: {}", user.getEmail());
        
        log.debug("🔹 [AuthService] Updating CIN information...");
        user.setCin(cin);
        user.setCinPhoto(cinPhotoPath);
        user.setIdentityVerified(true);
        
        log.debug("🔹 [AuthService] Saving updated user...");
        user = userRepository.save(user);
        log.info("✅ [AuthService] CIN verification saved for user ID: {}", userId);
        
        log.debug("🔹 [AuthService] Converting to DTO...");
        UserDTO userDTO = UserDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .username(user.getUsername())
                .identityVerified(user.getIdentityVerified())
                .cin(user.getCin())
                .cinPhoto(user.getCinPhoto())
                .build();
        
        log.info("✅ [AuthService] CIN verification completed for user: {}", user.getEmail());
        return userDTO;
    }
}
