package com.ethicalai.creditscoring.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.util.Enumeration;

/**
 * Filter to log all incoming HTTP requests and outgoing responses
 */
@Slf4j
@Component
public class RequestLoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        long startTime = System.currentTimeMillis();
        
        // Log incoming request
        logRequest(httpRequest);
        
        try {
            chain.doFilter(request, response);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            logResponse(httpRequest, httpResponse, duration);
        }
    }
    
    private void logRequest(HttpServletRequest request) {
        log.info("╔════════════════════════════════════════════════════════════════");
        log.info("║ INCOMING REQUEST");
        log.info("╠════════════════════════════════════════════════════════════════");
        log.info("║ Method: {} {}", request.getMethod(), request.getRequestURI());
        log.info("║ Remote Address: {}", request.getRemoteAddr());
        log.info("║ Content-Type: {}", request.getContentType());
        
        // Log headers
        log.info("║ Headers:");
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            // Don't log sensitive headers
            if (!headerName.equalsIgnoreCase("Authorization")) {
                log.info("║   {}: {}", headerName, request.getHeader(headerName));
            } else {
                log.info("║   {}: [HIDDEN]", headerName);
            }
        }
        
        // Log query parameters
        if (request.getQueryString() != null) {
            log.info("║ Query String: {}", request.getQueryString());
        }
        
        log.info("╚════════════════════════════════════════════════════════════════");
    }
    
    private void logResponse(HttpServletRequest request, HttpServletResponse response, long duration) {
        log.info("╔════════════════════════════════════════════════════════════════");
        log.info("║ OUTGOING RESPONSE");
        log.info("╠════════════════════════════════════════════════════════════════");
        log.info("║ Method: {} {}", request.getMethod(), request.getRequestURI());
        log.info("║ Status: {}", response.getStatus());
        log.info("║ Duration: {}ms", duration);
        log.info("║ Content-Type: {}", response.getContentType());
        log.info("╚════════════════════════════════════════════════════════════════");
    }
}
