# Backend Dockerfile - Spring Boot Application
FROM eclipse-temurin:21-jre-jammy

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy pre-built jar
COPY target/*.jar app.jar

# Create uploads directories
RUN mkdir -p /app/uploads/general /app/uploads/identity-scans && \
    chmod -R 755 /app/uploads

# Create logs directory
RUN mkdir -p /app/logs && chmod 755 /app/logs

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
