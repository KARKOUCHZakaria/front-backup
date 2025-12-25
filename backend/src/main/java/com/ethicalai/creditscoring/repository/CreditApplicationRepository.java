package com.ethicalai.creditscoring.repository;

import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CreditApplicationRepository extends JpaRepository<CreditApplication, Long> {
    
    List<CreditApplication> findByUserOrderByCreatedAtDesc(User user);
    
    Page<CreditApplication> findByUser(User user, Pageable pageable);
    
    Optional<CreditApplication> findByApplicationNumber(String applicationNumber);
    
    @Query("SELECT ca FROM CreditApplication ca WHERE ca.user.id = :userId AND ca.status = :status")
    List<CreditApplication> findByUserIdAndStatus(@Param("userId") Long userId, 
                                                   @Param("status") CreditApplication.ApplicationStatus status);
    
    @Query("SELECT COUNT(ca) FROM CreditApplication ca WHERE ca.user.id = :userId")
    long countByUserId(@Param("userId") Long userId);
    
    @Query("SELECT ca FROM CreditApplication ca WHERE ca.status IN :statuses ORDER BY ca.createdAt DESC")
    Page<CreditApplication> findByStatusIn(@Param("statuses") List<CreditApplication.ApplicationStatus> statuses, 
                                           Pageable pageable);
}
