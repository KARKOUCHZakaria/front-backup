package com.ethicalai.creditscoring.repository;

import com.ethicalai.creditscoring.entity.PredictionResult;
import com.ethicalai.creditscoring.entity.CreditApplication;
import com.ethicalai.creditscoring.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PredictionResultRepository extends JpaRepository<PredictionResult, Long> {
    
    Optional<PredictionResult> findByApplication(CreditApplication application);
    
    List<PredictionResult> findByUserOrderByTimestampDesc(User user);
    
    @Query("SELECT pr FROM PredictionResult pr WHERE pr.user.id = :userId ORDER BY pr.timestamp DESC")
    List<PredictionResult> findByUserId(@Param("userId") Long userId);
    
    Optional<PredictionResult> findByApplicationIdRef(String applicationIdRef);
    
    @Query("SELECT pr FROM PredictionResult pr WHERE pr.decision = :decision ORDER BY pr.timestamp DESC")
    List<PredictionResult> findByDecision(@Param("decision") String decision);
    
    @Query("SELECT COUNT(pr) FROM PredictionResult pr WHERE pr.user.id = :userId AND pr.decision = 'approved'")
    long countApprovedByUserId(@Param("userId") Long userId);
    
    @Query("SELECT AVG(pr.creditScore) FROM PredictionResult pr WHERE pr.user.id = :userId")
    Double getAverageCreditScoreByUserId(@Param("userId") Long userId);
}
