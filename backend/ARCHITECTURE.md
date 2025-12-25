# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Frontend                          │
│                    (Android/iOS/Web/Desktop)                     │
└──────────────────────┬──────────────────────────────────────────┘
                       │ REST API (JSON)
                       │ JWT Authentication
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Spring Boot Backend (Port 8081)               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     Security Layer                        │  │
│  │  • JWT Authentication Filter                             │  │
│  │  • BCrypt Password Encryption                            │  │
│  │  • CORS Configuration                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Controller Layer                        │  │
│  │  • AuthController                                        │  │
│  │  • ApplicationController                                 │  │
│  │  • DocumentController                                    │  │
│  │  • MLController                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Service Layer                          │  │
│  │  • AuthService                                           │  │
│  │  • CreditApplicationService                              │  │
│  │  • DocumentService                                       │  │
│  │  • MLService (WebClient integration)                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Repository Layer                        │  │
│  │  • UserRepository (Spring Data JPA)                      │  │
│  │  • CreditApplicationRepository                           │  │
│  │  • DocumentRepository                                    │  │
│  │  • PredictionResultRepository                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────┬───────────────────────┬──────────────────┘
                       │                       │
                       ↓                       ↓
        ┌──────────────────────┐   ┌──────────────────────┐
        │  PostgreSQL Database │   │  ML Service (Python) │
        │    (Port 5432)       │   │    (Port 8000)       │
        │                      │   │                      │
        │  • Users             │   │  • Credit Scoring    │
        │  • Applications      │   │  • SHAP Values       │
        │  • Documents         │   │  • Fairness Metrics  │
        │  • Predictions       │   │  • Model Info        │
        └──────────────────────┘   └──────────────────────┘
```

## Technology Stack

### Backend Framework
- **Spring Boot 3.2.0**: Modern Java framework
- **Spring Security**: JWT authentication
- **Spring Data JPA**: Database abstraction
- **Hibernate**: ORM implementation

### Database
- **PostgreSQL 14+**: Relational database
- **Flyway**: Database migration management
- **JSONB**: For SHAP values and metadata

### Security
- **JWT (jjwt 0.12.3)**: Token-based authentication
- **BCrypt**: Password hashing
- **Spring Security**: Authorization and authentication

### Communication
- **WebClient**: Async HTTP client for ML service
- **Jackson**: JSON serialization/deserialization
- **REST**: API design pattern

### Build & Testing
- **Maven**: Dependency management and build
- **JUnit 5**: Unit testing framework
- **Spring Boot Test**: Integration testing

## Data Flow

### 1. User Registration/Login
```
Frontend → POST /auth/register → AuthController
                                      ↓
                                 AuthService
                                      ↓
                              BCrypt Password Hash
                                      ↓
                                UserRepository
                                      ↓
                                  Database
                                      ↓
                                 JWT Token ← Generate
                                      ↓
                                  Frontend
```

### 2. Credit Application Submission
```
Frontend → POST /api/applications → ApplicationController
   (with JWT)                              ↓
                                 CreditApplicationService
                                      ↓
                              Save to Database
                                      ↓
                                  MLService
                                      ↓
                        WebClient → Python ML API
                                      ↓
                              Receive Prediction
                                      ↓
                          Save PredictionResult
                                      ↓
                        Update Application Status
                                      ↓
                         Return to Frontend
```

### 3. Document Upload
```
Frontend → POST /api/documents/upload → DocumentController
   (multipart)                                  ↓
                                      DocumentService
                                           ↓
                                  Validate File
                                           ↓
                                   Save to Disk
                                           ↓
                            Save Metadata to Database
                                           ↓
                                Return Document Info
```

## Database Schema

### Entity Relationships
```
User (1) ──────── (N) CreditApplication
  │                          │
  │                          │
  │                          ↓
  │                   PredictionResult (1:1)
  │
  ↓
Document (N)
  │
  └──────→ CreditApplication (optional N:1)
```

### Key Tables

**users**
- Primary identity and authentication
- BCrypt hashed passwords
- Role-based access control

**credit_applications**
- All ML model features
- Application status tracking
- Linked to user

**prediction_results**
- ML model outputs
- SHAP values (JSONB)
- Fairness metrics
- Linked to application and user

**documents**
- File metadata
- Document type classification
- Verification status
- Linked to user and optional application

## Security Architecture

### Authentication Flow
1. User provides email/password
2. Backend validates credentials
3. Generate JWT with 24-hour expiration
4. Return token to client
5. Client includes token in subsequent requests
6. JwtAuthenticationFilter validates token
7. SecurityContext populated with user details

### Authorization
- All `/api/**` endpoints require authentication
- `/auth/**` endpoints are public
- Role-based access can be added using `@PreAuthorize`

### Password Security
- BCrypt with automatic salt generation
- 10 rounds of hashing (2^10 iterations)
- Never stored in plain text
- Minimum 6 characters required

## ML Integration

### Communication Pattern
```
Backend ←→ Python ML Service
  (WebClient)
```

### Endpoints Used
- `POST /predict`: Get credit score prediction
- `POST /explain`: Get SHAP explanations
- `GET /fairness`: Get fairness metrics
- `GET /health`: Check service health

### Error Handling
- Timeout after 30 seconds
- Fallback to error response
- Logged for monitoring
- User-friendly error messages

## Scalability Considerations

### Current Setup (Single Instance)
- Suitable for development and small production
- Handles ~100 concurrent users
- Database connection pooling (10 connections)

### Horizontal Scaling
To scale horizontally:
1. Use external session storage (Redis) for JWT blacklist
2. Shared file storage (S3, MinIO) instead of local disk
3. Load balancer (Nginx, HAProxy)
4. Multiple backend instances
5. Database read replicas

### Performance Optimizations
- Connection pooling configured
- Lazy loading for JPA entities
- Pagination for list endpoints
- Async ML API calls with WebClient
- Database indexes on frequently queried columns

## Monitoring & Observability

### Health Checks
- Spring Actuator endpoints
- `/actuator/health` - Overall health
- `/actuator/metrics` - Performance metrics
- `/actuator/info` - Application info

### Logging
- Structured logging with SLF4J
- Log levels: DEBUG (dev), INFO (prod)
- File rotation (10MB max, 30 days retention)
- Request/response logging for debugging

### Error Tracking
- Consistent error response format
- Exception handling with @ControllerAdvice (recommended)
- Stack traces logged for investigation

## Deployment

### Development
```bash
mvn spring-boot:run
```

### Production
```bash
# Build JAR
mvn clean package -DskipTests

# Run with production profile
java -jar target/credit-scoring-backend-1.0.0.jar \
  --spring.profiles.active=prod \
  --server.port=8081
```

### Docker (Recommended)
```dockerfile
FROM openjdk:17-slim
COPY target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app.jar"]
```

## Future Enhancements

### Short Term
- [ ] Email verification service
- [ ] Password reset functionality
- [ ] Admin dashboard
- [ ] Application status notifications
- [ ] Document verification workflow

### Long Term
- [ ] Redis caching layer
- [ ] Elasticsearch for document search
- [ ] Kafka for event streaming
- [ ] Microservices architecture
- [ ] Kubernetes deployment
- [ ] API rate limiting
- [ ] API versioning

---

**Architecture Version**: 1.0.0  
**Last Updated**: December 23, 2025
