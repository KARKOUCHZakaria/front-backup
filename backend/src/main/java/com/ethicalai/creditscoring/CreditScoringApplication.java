package com.ethicalai.creditscoring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Main Application Class for Ethical AI Credit Scoring Backend
 */
@SpringBootApplication
public class CreditScoringApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(CreditScoringApplication.class, args);
    }
    
    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }
}
