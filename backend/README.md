# Ethical AI Credit Scoring Backend

A comprehensive Spring Boot backend API for the Ethical AI Credit Scoring application. This backend provides secure authentication, credit application management, document handling, and ML prediction integration.

## 🏗️ Architecture

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/ethicalai/creditscoring/
│   │   │   ├── controller/          # REST API Controllers
│   │   │   │   ├── AuthController.java
│   │   │   │   ├── ApplicationController.java
│   │   │   │   ├── DocumentController.java
│   │   │   │   └── MLController.java
│   │   │   ├── service/             # Business Logic Layer
│   │   │   │   ├── AuthService.java
│   │   │   │   ├── CreditApplicationService.java
│   │   │   │   ├── DocumentService.java
│   │   │   │   ├── MLService.java
│   │   │   │   └── UserDetailsServiceImpl.java
│   │   │   ├── repository/          # Data Access Layer
│   │   │   │   ├── UserRepository.java
│   │   │   │   ├── CreditApplicationRepository.java
│   │   │   │   ├── DocumentRepository.java
│   │   │   │   └── PredictionResultRepository.java
│   │   │   ├── entity/              # JPA Entities
│   │   │   │   ├── User.java
│   │   │   │   ├── CreditApplication.java
│   │   │   │   ├── Document.java
│   │   │   │   └── PredictionResult.java
│   │   │   ├── dto/                 # Data Transfer Objects
│   │   │   │   ├── AuthRequest.java
│   │   │   │   ├── UserDTO.java
│   │   │   │   ├── CreditApplicationDTO.java
│   │   │   │   ├── PredictionResultDTO.java
│   │   │   │   └── ApiResponse.java
│   │   │   ├── security/            # Security Configuration
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   ├── JwtUtil.java
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   └── JwtAuthenticationEntryPoint.java
│   │   │   └── CreditScoringApplication.java
│   │   └── resources/
│   │       ├── application.yml      # Application Configuration
│   │       └── db/migration/        # Flyway Database Migrations
│   └── test/                        # Unit and Integration Tests
└── pom.xml                          # Maven Dependencies

```

## 🚀 Features

### Core Functionality
- ✅ **User Authentication**: JWT-based secure authentication with BCrypt password hashing
- ✅ **Credit Application Management**: Complete CRUD operations for credit applications
- ✅ **Document Upload**: Secure file upload with validation and storage
- ✅ **ML Integration**: Real-time credit scoring with ML service integration
- ✅ **SHAP Explanations**: Explainable AI with SHAP value computation
- ✅ **Fairness Metrics**: Bias detection and fairness assessment
- ✅ **Application History**: Track and manage all user applications
- ✅ **Identity Verification**: CIN verification with photo upload

### Technical Features
- 🔐 Spring Security with JWT authentication
- 🗄️ PostgreSQL database with Flyway migrations
- 📝 RESTful API design
- 🔄 Asynchronous ML API calls with WebClient
- 📊 Comprehensive logging and error handling
- 🏥 Health check endpoints with Spring Actuator
- 🔗 CORS configuration for Flutter frontend

## 📋 Prerequisites

- **Java 17** or higher
- **Maven 3.8+**
- **PostgreSQL 14+**
- **Python ML Service** (running on port 8000)

## ⚙️ Configuration

### Database Setup

1. Create PostgreSQL database:
```sql
CREATE DATABASE credit_scoring_db;
CREATE USER credit_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE credit_scoring_db TO credit_user;
```

2. Update `src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/credit_scoring_db
    username: credit_user
    password: your_password
```

### Environment Variables

Set the following environment variables or update `application.yml`:

```bash
# Database
export DB_USERNAME=credit_user
export DB_PASSWORD=your_password

# JWT Secret (minimum 256 bits)
export JWT_SECRET=YourSuperSecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLong

# ML Service URL
export ML_SERVICE_URL=http://localhost:8000

# File Upload Directory
export FILE_UPLOAD_DIR=./uploads
```

### Application Properties

Key configuration in `application.yml`:

```yaml
server:
  port: 8081

app:
  jwt:
    secret: ${JWT_SECRET}
    expiration: 86400000  # 24 hours
  
  ml-service:
    url: ${ML_SERVICE_URL:http://localhost:8000}
  
  file-upload:
    directory: ${FILE_UPLOAD_DIR:./uploads}
    allowed-extensions: pdf,jpg,jpeg,png
    max-size: 10485760  # 10MB
```

## 🔧 Installation & Running

### 1. Clone and Build

```bash
cd backend
mvn clean install
```

### 2. Run the Application

```bash
# Using Maven
mvn spring-boot:run

# Or using Java
java -jar target/credit-scoring-backend-1.0.0.jar
```

### 3. Verify Installation

Check if the server is running:
```bash
curl http://localhost:8081/actuator/health
```

Expected response:
```json
{
  "status": "UP"
}
```

## 📡 API Endpoints

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "John Doe",
  "password": "password123"
}
```

Response:
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "John Doe",
  "identityVerified": false,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Verify CIN
```http
POST /auth/verify-cin
Authorization: Bearer {token}
Content-Type: multipart/form-data

userId: 1
cin: AB123456
cinPhoto: [file]
```

### Application Endpoints

#### Submit Credit Application
```http
POST /api/applications
Authorization: Bearer {token}
Content-Type: application/json

{
  "CODE_GENDER": "M",
  "DAYS_BIRTH": -10950,
  "AMT_INCOME_TOTAL": 50000,
  "AMT_CREDIT": 200000,
  "AMT_ANNUITY": 15000,
  "NAME_EDUCATION_TYPE": "Higher education",
  "NAME_FAMILY_STATUS": "Married",
  "CNT_CHILDREN": 1,
  ...
}
```

Response:
```json
{
  "success": true,
  "message": "Application submitted successfully",
  "data": {
    "application_id": "APP-12345",
    "credit_score": 750,
    "decision": "approved",
    "confidence": 0.85,
    "prediction_probability": 0.15,
    "risk_level": "low",
    "shap_values": {
      "AMT_INCOME_TOTAL": 0.12,
      "AMT_CREDIT": -0.08,
      ...
    },
    "timestamp": "2025-12-23T10:30:00"
  }
}
```

#### Get User Applications
```http
GET /api/applications/user/{userId}
Authorization: Bearer {token}
```

#### Get Single Application
```http
GET /api/applications/{applicationId}
Authorization: Bearer {token}
```

### Document Endpoints

#### Upload Document
```http
POST /api/documents/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [file]
documentType: PAY_SLIP
applicationId: 1 (optional)
```

#### Get User Documents
```http
GET /api/documents/user/{userId}
Authorization: Bearer {token}
```

#### Download Document
```http
GET /api/documents/{documentId}
Authorization: Bearer {token}
```

#### Delete Document
```http
DELETE /api/documents/{documentId}
Authorization: Bearer {token}
```

### ML Endpoints

#### Get SHAP Explanation
```http
POST /api/ml/explain
Authorization: Bearer {token}
Content-Type: application/json

{
  "CODE_GENDER": "M",
  "AMT_INCOME_TOTAL": 50000,
  ...
}
```

#### Get Fairness Metrics
```http
GET /api/ml/fairness?protectedAttribute=CODE_GENDER
Authorization: Bearer {token}
```

#### Check ML Service Health
```http
GET /api/ml/health
Authorization: Bearer {token}
```

## 🗄️ Database Schema

### Users Table
- `id`: Primary key
- `email`: Unique user email
- `username`: User display name
- `password`: BCrypt hashed password
- `identity_verified`: CIN verification status
- `cin`: National ID number
- `phone`, `country_code`: Contact information
- `role`: USER, ADMIN, AGENT
- `created_at`, `updated_at`, `last_login`: Timestamps

### Credit Applications Table
- All ML model features (CODE_GENDER, DAYS_BIRTH, AMT_INCOME_TOTAL, etc.)
- `status`: DRAFT, PENDING, PROCESSING, APPROVED, REJECTED, UNDER_REVIEW, CANCELLED
- `application_number`: Unique application identifier

### Documents Table
- File metadata and storage information
- `document_type`: PAY_SLIP, TAX_DECLARATION, CIN_PHOTO, etc.
- Linked to users and applications

### Prediction Results Table
- ML prediction results
- SHAP values (JSONB)
- Fairness metrics
- Processing metadata

## 🔒 Security

### JWT Authentication
- Tokens expire after 24 hours
- Secure secret key (256+ bits)
- Bearer token in Authorization header

### Password Security
- BCrypt hashing with salt
- Minimum 6 characters required

### File Upload Security
- File type validation (pdf, jpg, jpeg, png)
- Maximum file size: 10MB
- Secure file storage with UUID naming

### CORS Configuration
- Configured for Flutter frontend
- Allows credentials and specific origins

## 🧪 Testing

Run tests with Maven:
```bash
mvn test
```

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:8081/actuator/health
```

### Application Info
```bash
curl http://localhost:8081/actuator/info
```

### Metrics
```bash
curl http://localhost:8081/actuator/metrics
```

## 🔗 Integration with Frontend

The backend is designed to work seamlessly with the Flutter frontend:

1. **Base URL Configuration**: Frontend points to `http://10.0.2.2:8081` (Android emulator) or `http://localhost:8081`
2. **Model Matching**: All DTOs match Flutter model classes exactly
3. **JSON Naming**: Uses snake_case for ML fields, camelCase for auth fields
4. **Error Handling**: Returns consistent ApiResponse wrapper

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Test PostgreSQL connection
psql -h localhost -U credit_user -d credit_scoring_db
```

### ML Service Connection Issues
```bash
# Test ML service
curl http://localhost:8000/health
```

### JWT Token Issues
- Ensure JWT_SECRET is set and at least 256 bits
- Check token expiration time
- Verify token format: `Bearer {token}`

### File Upload Issues
- Check upload directory exists and is writable
- Verify file size under 10MB
- Confirm file extension is allowed

## 📝 Development Notes

### Adding New Endpoints
1. Create/update entity in `entity/`
2. Create repository interface in `repository/`
3. Implement service logic in `service/`
4. Create REST controller in `controller/`
5. Add database migration if needed

### Database Migrations
Flyway automatically runs migrations on startup. Create new migrations:
```
V3__Your_Migration_Name.sql
```

## 📄 License

This project is part of the Ethical AI Credit Scoring system.

## 👥 Support

For issues or questions, please contact the development team.

---

**Built with ❤️ using Spring Boot 3.2, Java 17, and PostgreSQL**
