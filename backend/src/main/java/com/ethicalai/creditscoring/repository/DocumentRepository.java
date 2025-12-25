package com.ethicalai.creditscoring.repository;

import com.ethicalai.creditscoring.entity.Document;
import com.ethicalai.creditscoring.entity.User;
import com.ethicalai.creditscoring.entity.CreditApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {
    
    List<Document> findByUser(User user);
    
    List<Document> findByUserOrderByUploadedAtDesc(User user);
    
    List<Document> findByApplication(CreditApplication application);
    
    @Query("SELECT d FROM Document d WHERE d.user.id = :userId")
    List<Document> findByUserId(@Param("userId") Long userId);
    
    @Query("SELECT d FROM Document d WHERE d.application.id = :applicationId")
    List<Document> findByApplicationId(@Param("applicationId") Long applicationId);
    
    List<Document> findByDocumentType(Document.DocumentType documentType);
    
    @Query("SELECT d FROM Document d WHERE d.user.id = :userId AND d.documentType = :documentType")
    List<Document> findByUserIdAndDocumentType(@Param("userId") Long userId, 
                                                @Param("documentType") Document.DocumentType documentType);
}
