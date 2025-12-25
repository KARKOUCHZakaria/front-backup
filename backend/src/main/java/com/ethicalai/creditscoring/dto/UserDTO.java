package com.ethicalai.creditscoring.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * User Response DTO matching frontend User model
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    
    private Long id;
    
    private String email;
    
    private String username;
    
    @JsonProperty("identityVerified")
    private Boolean identityVerified;
    
    private String cin;
    
    @JsonProperty("cinPhoto")
    private String cinPhoto;
    
    private String token;
    
    private String phone;
    
    @JsonProperty("countryCode")
    private String countryCode;
}
