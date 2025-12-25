package com.ethicalai.creditscoring.controller;

import com.ethicalai.creditscoring.dto.ApiResponse;
import com.ethicalai.creditscoring.entity.Document;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.repository.UserRepository;
import com.ethicalai.creditscoring.service.DocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

/**
 * Document Controller
 */
@Slf4j
@RestController
@RequestMapping("/api/documents")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@RequiredArgsConstructor
public class DocumentController {
    
    private final DocumentService documentService;
    private final UserRepository userRepository;
    
    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<Document>> uploadDocument(
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") Document.DocumentType documentType,
            @RequestParam(value = "applicationId", required = false) Long applicationId,
            Authentication authentication) {
        log.info("🔵 UPLOAD DOCUMENT - User: {}, Type: {}, File: {}, Size: {} bytes", 
                authentication.getName(), documentType, file.getOriginalFilename(), file.getSize());
        try {
            // Get authenticated user
            User user = userRepository.findByEmail(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            log.info("📄 Processing upload for User ID: {}", user.getId());
            
            Document document = documentService.uploadDocument(user.getId(), file, documentType, applicationId);
            log.info("✅ Document uploaded - ID: {}, Path: {}", document.getId(), document.getFilePath());
            
            return ResponseEntity.ok(ApiResponse.success("Document uploaded successfully", document));
        } catch (Exception e) {
            log.error("❌ UPLOAD FAILED - User: {}, File: {}, Error: {}", 
                    authentication.getName(), file.getOriginalFilename(), e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("UPLOAD_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Document>>> getUserDocuments(@PathVariable Long userId) {
        log.info("🔵 GET USER DOCUMENTS - User ID: {}", userId);
        try {
            List<Document> documents = documentService.getUserDocuments(userId);
            log.info("✅ Found {} documents for User ID: {}", documents.size(), userId);
            return ResponseEntity.ok(ApiResponse.success(documents));
        } catch (Exception e) {
            log.error("❌ FETCH DOCUMENTS FAILED - User ID: {}, Error: {}", 
                    userId, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("FETCH_FAILED", e.getMessage()));
        }
    }
    
    @GetMapping("/{documentId}")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Long documentId) {
        log.info("🔵 DOWNLOAD DOCUMENT - Document ID: {}", documentId);
        try {
            Document document = documentService.getDocumentById(documentId);
            Path filePath = Paths.get(document.getFilePath());
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                log.info("✅ Document downloaded - ID: {}, File: {}, Size: {} bytes", 
                        documentId, document.getFileName(), document.getFileSize());
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(document.getMimeType()))
                        .header(HttpHeaders.CONTENT_DISPOSITION, 
                                "attachment; filename=\"" + document.getFileName() + "\"")
                        .body(resource);
            } else {
                throw new RuntimeException("File not found or not readable");
            }
        } catch (Exception e) {
            log.error("❌ DOWNLOAD FAILED - Document ID: {}, Error: {}", 
                    documentId, e.getMessage(), e);
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{documentId}")
    public ResponseEntity<ApiResponse<Void>> deleteDocument(@PathVariable Long documentId) {
        log.info("🔵 DELETE DOCUMENT - Document ID: {}", documentId);
        try {
            documentService.deleteDocument(documentId);
            log.info("✅ Document deleted - ID: {}", documentId);
            return ResponseEntity.ok(ApiResponse.success("Document deleted successfully", null));
        } catch (Exception e) {
            log.error("❌ DELETE FAILED - Document ID: {}, Error: {}", 
                    documentId, e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("DELETE_FAILED", e.getMessage()));
        }
    }
}
