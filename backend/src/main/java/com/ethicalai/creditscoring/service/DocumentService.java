package com.ethicalai.creditscoring.service;

import com.ethicalai.creditscoring.entity.Document;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.repository.DocumentRepository;
import com.ethicalai.creditscoring.repository.UserRepository;
import com.ethicalai.creditscoring.repository.CreditApplicationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

/**
 * Document Service for handling file uploads and management
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DocumentService {
    
    private final DocumentRepository documentRepository;
    private final UserRepository userRepository;
    private final CreditApplicationRepository applicationRepository;
    
    @Value("${app.file-upload.directory}")
    private String uploadDirectory;
    
    @Value("${app.file-upload.allowed-extensions}")
    private String allowedExtensions;
    
    @Value("${app.file-upload.max-size}")
    private long maxFileSize;
    
    @Transactional
    public Document uploadDocument(Long userId, MultipartFile file, Document.DocumentType documentType, Long applicationId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Validate file
        validateFile(file);
        
        // Save file to disk
        String fileName = generateFileName(file.getOriginalFilename());
        String filePath = saveFile(file, fileName);
        
        // Create document entity
        Document document = Document.builder()
                .user(user)
                .documentType(documentType)
                .fileName(file.getOriginalFilename())
                .filePath(filePath)
                .fileSize(file.getSize())
                .mimeType(file.getContentType())
                .fileExtension(FilenameUtils.getExtension(file.getOriginalFilename()))
                .isVerified(false)
                .build();
        
        // Associate with application if provided
        if (applicationId != null) {
            CreditApplication application = applicationRepository.findById(applicationId)
                    .orElseThrow(() -> new RuntimeException("Application not found"));
            document.setApplication(application);
        }
        
        return documentRepository.save(document);
    }
    
    public List<Document> getUserDocuments(Long userId) {
        return documentRepository.findByUserId(userId);
    }
    
    public List<Document> getApplicationDocuments(Long applicationId) {
        return documentRepository.findByApplicationId(applicationId);
    }
    
    public Document getDocumentById(Long documentId) {
        return documentRepository.findById(documentId)
                .orElseThrow(() -> new RuntimeException("Document not found"));
    }
    
    @Transactional
    public void deleteDocument(Long documentId) {
        Document document = getDocumentById(documentId);
        
        // Delete file from disk
        try {
            Files.deleteIfExists(Paths.get(document.getFilePath()));
        } catch (IOException e) {
            log.error("Error deleting file: {}", document.getFilePath(), e);
        }
        
        documentRepository.delete(document);
    }
    
    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new RuntimeException("File is empty");
        }
        
        if (file.getSize() > maxFileSize) {
            throw new RuntimeException("File size exceeds maximum allowed size");
        }
        
        String extension = FilenameUtils.getExtension(file.getOriginalFilename());
        if (!allowedExtensions.contains(extension.toLowerCase())) {
            throw new RuntimeException("File type not allowed. Allowed types: " + allowedExtensions);
        }
    }
    
    private String saveFile(MultipartFile file, String fileName) {
        try {
            Path uploadPath = Paths.get(uploadDirectory);
            
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            return filePath.toString();
            
        } catch (IOException e) {
            log.error("Error saving file", e);
            throw new RuntimeException("Failed to save file: " + e.getMessage());
        }
    }
    
    private String generateFileName(String originalFileName) {
        String extension = FilenameUtils.getExtension(originalFileName);
        String uuid = UUID.randomUUID().toString();
        return uuid + "." + extension;
    }
}
