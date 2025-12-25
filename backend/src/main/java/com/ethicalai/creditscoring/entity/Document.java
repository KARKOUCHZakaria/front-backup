package com.ethicalai.creditscoring.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * Document entity for storing user uploaded documents
 */
@Entity
@Table(name = "documents", indexes = {
    @Index(name = "idx_doc_user_id", columnList = "user_id"),
    @Index(name = "idx_doc_application_id", columnList = "application_id"),
    @Index(name = "idx_doc_type", columnList = "document_type")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Document {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "application_id")
    private CreditApplication application;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "document_type", nullable = false, length = 50)
    private DocumentType documentType;
    
    @Column(name = "file_name", nullable = false)
    private String fileName;
    
    @Column(name = "file_path", nullable = false)
    private String filePath;
    
    @Column(name = "file_size")
    private Long fileSize; // in bytes
    
    @Column(name = "mime_type", length = 100)
    private String mimeType;
    
    @Column(name = "file_extension", length = 10)
    private String fileExtension;
    
    @Column(name = "is_verified")
    private Boolean isVerified = false;
    
    @Column(name = "verification_status", length = 20)
    private String verificationStatus;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @CreationTimestamp
    @Column(name = "uploaded_at", nullable = false, updatable = false)
    private LocalDateTime uploadedAt;
    
    public enum DocumentType {
        PAY_SLIP,
        TAX_DECLARATION,
        INCOME_CONSISTENCY,
        LOAN_PAYMENTS,
        BUSINESS_CERTIFICATE,
        INCOME_DECLARATION,
        CIN_PHOTO,
        CIN_FRONT,
        CIN_BACK,
        BANK_STATEMENT,
        PROOF_OF_ADDRESS,
        OTHER
    }
}
