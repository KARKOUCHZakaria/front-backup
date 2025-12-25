package com.ethicalai.creditscoring.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * API Error details
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiError {
    
    private String code;
    
    private String message;
    
    private Map<String, Object> details;
}
