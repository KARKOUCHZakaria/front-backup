# API Documentation

## Complete API Reference for Ethical AI Credit Scoring Backend

### Base URL
- **Development**: `http://localhost:8081`
- **Android Emulator**: `http://10.0.2.2:8081`

### Authentication
All endpoints except `/auth/**` and `/actuator/**` require JWT Bearer token:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Authentication API

### POST /auth/register
Register a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "username": "John Doe",
  "password": "password123"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "John Doe",
  "identityVerified": false,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**
- `400 Bad Request`: Email already registered
- `400 Bad Request`: Invalid email format
- `400 Bad Request`: Password too short

---

### POST /auth/login
Authenticate user and receive JWT token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "John Doe",
  "identityVerified": true,
  "phone": "+212612345678",
  "countryCode": "+212",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors:**
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: User not found

---

### POST /auth/verify-cin
Verify user's national ID (CIN) with photo upload.

**Request:** `multipart/form-data`
```
userId: 1
cin: AB123456
cinPhoto: [file upload]
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "CIN verified successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "John Doe",
    "identityVerified": true,
    "cin": "AB123456",
    "cinPhoto": "path/to/cin/photo.jpg"
  }
}
```

---

## Application API

### POST /api/applications
Submit a new credit application with ML prediction.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
  "CODE_GENDER": "M",
  "DAYS_BIRTH": -10950,
  "NAME_EDUCATION_TYPE": "Higher education",
  "NAME_FAMILY_STATUS": "Married",
  "CNT_CHILDREN": 1,
  "AMT_INCOME_TOTAL": 50000.00,
  "AMT_CREDIT": 200000.00,
  "AMT_ANNUITY": 15000.00,
  "AMT_GOODS_PRICE": 180000.00,
  "DAYS_EMPLOYED": -1825,
  "OCCUPATION_TYPE": "Managers",
  "ORGANIZATION_TYPE": "Business Entity Type 3",
  "NAME_CONTRACT_TYPE": "Cash loans",
  "NAME_INCOME_TYPE": "Working",
  "NAME_HOUSING_TYPE": "House / apartment",
  "FLAG_OWN_CAR": "Y",
  "FLAG_OWN_REALTY": "Y",
  "REGION_RATING_CLIENT": 2,
  "EXT_SOURCE_1": null,
  "EXT_SOURCE_2": null,
  "EXT_SOURCE_3": null
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Application submitted successfully",
  "data": {
    "application_id": "APP-A7B3C9D1",
    "prediction_probability": 0.12,
    "credit_score": 750,
    "decision": "approved",
    "confidence": 0.88,
    "risk_level": "low",
    "shap_values": {
      "AMT_INCOME_TOTAL": 0.15,
      "AMT_CREDIT": -0.08,
      "EXT_SOURCE_2": 0.22,
      "DAYS_BIRTH": 0.05,
      "DAYS_EMPLOYED": 0.03
    },
    "fairness_metrics": {
      "demographic_parity": 0.02,
      "equal_opportunity": 0.01,
      "disparate_impact": 0.98,
      "average_odds_difference": 0.015,
      "fairness_score": 95
    },
    "timestamp": "2025-12-23T10:30:00"
  }
}
```

---

### GET /api/applications/user/{userId}
Get all applications for a specific user.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "CODE_GENDER": "M",
      "DAYS_BIRTH": -10950,
      "AMT_INCOME_TOTAL": 50000.00,
      ...
    }
  ]
}
```

---

### GET /api/applications/{applicationId}
Get a specific application by ID.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "CODE_GENDER": "M",
    "DAYS_BIRTH": -10950,
    ...
  }
}
```

---

## Document API

### POST /api/documents/upload
Upload a document (PDF, JPG, JPEG, PNG).

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request:**
```
file: [file upload]
documentType: PAY_SLIP
applicationId: 1 (optional)
```

**Document Types:**
- `PAY_SLIP`
- `TAX_DECLARATION`
- `INCOME_CONSISTENCY`
- `LOAN_PAYMENTS`
- `BUSINESS_CERTIFICATE`
- `INCOME_DECLARATION`
- `CIN_PHOTO`
- `BANK_STATEMENT`
- `PROOF_OF_ADDRESS`
- `OTHER`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Document uploaded successfully",
  "data": {
    "id": 1,
    "fileName": "payslip.pdf",
    "fileSize": 524288,
    "documentType": "PAY_SLIP",
    "uploadedAt": "2025-12-23T10:30:00",
    "isVerified": false
  }
}
```

**Errors:**
- `400 Bad Request`: File too large (max 10MB)
- `400 Bad Request`: File type not allowed

---

### GET /api/documents/user/{userId}
Get all documents for a user.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "fileName": "payslip.pdf",
      "fileSize": 524288,
      "documentType": "PAY_SLIP",
      "uploadedAt": "2025-12-23T10:30:00",
      "isVerified": false
    }
  ]
}
```

---

### GET /api/documents/{documentId}
Download a specific document.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
- Content-Type: `application/pdf` or `image/jpeg` etc.
- Content-Disposition: `attachment; filename="payslip.pdf"`
- Binary file data

---

### DELETE /api/documents/{documentId}
Delete a document.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Document deleted successfully"
}
```

---

## ML API

### POST /api/ml/explain
Get SHAP explanation values for application features.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request:**
```json
{
  "CODE_GENDER": "M",
  "DAYS_BIRTH": -10950,
  "AMT_INCOME_TOTAL": 50000.00,
  ...
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "SHAP values computed successfully",
  "data": {
    "AMT_INCOME_TOTAL": 0.15,
    "AMT_CREDIT": -0.08,
    "EXT_SOURCE_2": 0.22,
    "DAYS_BIRTH": 0.05,
    "DAYS_EMPLOYED": 0.03
  }
}
```

---

### GET /api/ml/fairness
Get fairness metrics for the ML model.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `protectedAttribute` (optional): Default is `CODE_GENDER`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Fairness metrics computed successfully",
  "data": {
    "demographic_parity": 0.02,
    "equal_opportunity": 0.01,
    "disparate_impact": 0.98,
    "average_odds_difference": 0.015,
    "fairness_score": 95
  }
}
```

---

### GET /api/ml/health
Check if ML service is healthy.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "ML service is healthy",
  "data": true
}
```

---

## Error Responses

All endpoints may return these error responses:

### 400 Bad Request
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters"
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "status": 401,
  "error": "Unauthorized",
  "message": "JWT token is missing or invalid",
  "path": "/api/applications"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Resource not found"
  }
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred"
  }
}
```

---

## Rate Limiting

Currently no rate limiting is implemented. In production, consider adding rate limiting for:
- Authentication endpoints: 5 requests per minute
- Application submission: 10 requests per hour
- Document upload: 20 requests per hour

---

## Testing with cURL

### Register User
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"Test User","password":"password123"}'
```

### Login
```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Submit Application
```bash
curl -X POST http://localhost:8081/api/applications \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d @application_data.json
```

---

**API Version**: 1.0.0  
**Last Updated**: December 23, 2025
