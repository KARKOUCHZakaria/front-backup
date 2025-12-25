package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * File Upload Controller
 * Handles file uploads for CIN photos and other documents
 */
@Slf4j
@RestController
@RequestMapping("/api/files")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "File Upload", description = "File upload endpoints for images and documents")
public class FileUploadController {
    
    @Value("${app.file-upload.directory}")
    private String uploadDirectory;
    
    @Value("${app.file-upload.identity-scan-directory}")
    private String identityScanDirectory;
    
    @Operation(summary = "Upload CIN photo", description = "Upload a CIN (ID card) photo for identity verification")
    @PostMapping("/upload-cin")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadCinPhoto(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "userId", required = false) Long userId,
            @RequestParam(value = "cin", required = false) String cin) {
        
        log.info("🔵 [FileUpload] CIN UPLOAD REQUEST - User ID: {}, CIN: {}, File: {}, Size: {} bytes", 
                userId, cin, file.getOriginalFilename(), file.getSize());
        
        try {
            // Validate file
            if (file.isEmpty()) {
                log.error("❌ [FileUpload] Empty file received");
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File is empty"));
            }
            
            // Validate file type
            String contentType = file.getContentType();
            log.debug("🔹 [FileUpload] Content type: {}", contentType);
            
            if (contentType == null || !contentType.startsWith("image/")) {
                log.error("❌ [FileUpload] Invalid file type: {}", contentType);
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Only image files are allowed"));
            }
            
            // Validate file size (max 10MB)
            if (file.getSize() > 10 * 1024 * 1024) {
                log.error("❌ [FileUpload] File too large: {} bytes", file.getSize());
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size must be less than 10MB"));
            }
            
            // Create upload directory if it doesn't exist
            log.debug("🔹 [FileUpload] Creating directory: {}", identityScanDirectory);
            Path uploadPath = Paths.get(identityScanDirectory);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
                log.info("✅ [FileUpload] Created directory: {}", identityScanDirectory);
            }
            
            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String fileExtension = originalFilename != null && originalFilename.contains(".") 
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            
            String filename = String.format("cin_%s_%s%s",
                    userId != null ? userId : "temp",
                    UUID.randomUUID().toString().substring(0, 8),
                    fileExtension);
            
            log.debug("🔹 [FileUpload] Generated filename: {}", filename);
            
            // Save file
            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            log.info("✅ [FileUpload] File saved successfully: {}", filePath);
            
            // Prepare response
            Map<String, String> response = new HashMap<>();
            response.put("filename", filename);
            response.put("filepath", filePath.toString());
            response.put("url", "/api/files/cin/" + filename);
            response.put("size", String.valueOf(file.getSize()));
            response.put("contentType", contentType);
            
            log.info("✅ [FileUpload] CIN upload completed - Filename: {}", filename);
            
            return ResponseEntity.ok(ApiResponse.success("File uploaded successfully", response));
            
        } catch (IOException e) {
            log.error("❌ [FileUpload] Failed to upload file", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload file: " + e.getMessage()));
        }
    }
    
    @Operation(summary = "Upload general document", description = "Upload any document or image")
    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "category", defaultValue = "general") String category) {
        
        log.info("🔵 [FileUpload] GENERAL UPLOAD REQUEST - File: {}, Size: {} bytes, Category: {}", 
                file.getOriginalFilename(), file.getSize(), category);
        
        try {
            // Validate file
            if (file.isEmpty()) {
                log.error("❌ [FileUpload] Empty file received");
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File is empty"));
            }
            
            // Validate file size (max 10MB)
            if (file.getSize() > 10 * 1024 * 1024) {
                log.error("❌ [FileUpload] File too large: {} bytes", file.getSize());
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("File size must be less than 10MB"));
            }
            
            // Create category-specific directory
            String categoryDir = uploadDirectory + "/" + category;
            log.debug("🔹 [FileUpload] Creating directory: {}", categoryDir);
            Path uploadPath = Paths.get(categoryDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
                log.info("✅ [FileUpload] Created directory: {}", categoryDir);
            }
            
            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String fileExtension = originalFilename != null && originalFilename.contains(".") 
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : "";
            
            String filename = String.format("%s_%s%s",
                    System.currentTimeMillis(),
                    UUID.randomUUID().toString().substring(0, 8),
                    fileExtension);
            
            log.debug("🔹 [FileUpload] Generated filename: {}", filename);
            
            // Save file
            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            log.info("✅ [FileUpload] File saved successfully: {}", filePath);
            
            // Prepare response
            Map<String, String> response = new HashMap<>();
            response.put("filename", filename);
            response.put("filepath", filePath.toString());
            response.put("url", "/api/files/" + category + "/" + filename);
            response.put("size", String.valueOf(file.getSize()));
            response.put("contentType", file.getContentType());
            response.put("category", category);
            
            log.info("✅ [FileUpload] Upload completed - Filename: {}", filename);
            
            return ResponseEntity.ok(ApiResponse.success("File uploaded successfully", response));
            
        } catch (IOException e) {
            log.error("❌ [FileUpload] Failed to upload file", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to upload file: " + e.getMessage()));
        }
    }
    
    @Operation(summary = "Download CIN photo", description = "Download CIN photo by filename")
    @GetMapping("/cin/{filename:.+}")
    public ResponseEntity<Resource> downloadCinPhoto(@PathVariable String filename) {
        log.info("🔵 [FileUpload] DOWNLOAD CIN PHOTO - Filename: {}", filename);
        
        try {
            Path filePath = Paths.get(identityScanDirectory).resolve(filename).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                // Determine content type
                String contentType = Files.probeContentType(filePath);
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }
                
                log.info("✅ [FileUpload] Serving CIN photo - Filename: {}, ContentType: {}", filename, contentType);
                
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                        .body(resource);
            } else {
                log.error("❌ [FileUpload] CIN photo not found: {}", filename);
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            log.error("❌ [FileUpload] Invalid file path: {}", filename, e);
            return ResponseEntity.badRequest().build();
        } catch (IOException e) {
            log.error("❌ [FileUpload] Error reading CIN photo: {}", filename, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @Operation(summary = "Get uploaded file URL", description = "Get the URL to access an uploaded file")
    @GetMapping("/url/{category}/{filename}")
    public ResponseEntity<ApiResponse<Map<String, String>>> getFileUrl(
            @PathVariable String category,
            @PathVariable String filename) {
        
        log.info("🔵 [FileUpload] GET FILE URL - Category: {}, Filename: {}", category, filename);
        
        Map<String, String> response = new HashMap<>();
        response.put("url", "/api/files/" + category + "/" + filename);
        response.put("filename", filename);
        response.put("category", category);
        
        return ResponseEntity.ok(ApiResponse.success("File URL retrieved", response));
    }
}
