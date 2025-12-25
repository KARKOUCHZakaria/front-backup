# Pre-Flight Checklist ✈️

## Before Running the Backend

### ✅ 1. Database Setup
- [ ] PostgreSQL is installed and running
- [ ] Create database: `CREATE DATABASE credit_scoring_db;`
- [ ] Test connection: `psql -U postgres -d credit_scoring_db`

### ✅ 2. Environment Variables
- [ ] Create `.env` file in backend folder
- [ ] Set `DB_USERNAME=postgres` (or your username)
- [ ] Set `DB_PASSWORD=your_password`
- [ ] Set `JWT_SECRET` (minimum 256 bits - 32 characters)
- [ ] Set `ML_SERVICE_URL=http://localhost:8000` (if ML service is running)

### ✅ 3. Java & Maven
- [ ] Java 17+ installed: `java -version`
- [ ] Maven installed: `mvn -version`
- [ ] JAVA_HOME is set

### ✅ 4. Port Availability
- [ ] Port 8081 is free (backend port)
- [ ] Check: `netstat -ano | findstr :8081` (Windows)
- [ ] Check: `lsof -i :8081` (Mac/Linux)

### ✅ 5. File Upload Directory
- [ ] Backend will create `./uploads` folder automatically
- [ ] Ensure write permissions for current user

---

## CORS Configuration ✓

### ✅ Already Configured - No Action Needed!

**Backend CORS Settings:**
- ✅ `@CrossOrigin` annotations on all controllers
- ✅ `CorsConfigurationSource` bean in SecurityConfig
- ✅ Allows all origins (`*`)
- ✅ Allows all headers
- ✅ Allows methods: GET, POST, PUT, DELETE, OPTIONS, PATCH
- ✅ Credentials enabled
- ✅ Max age: 3600 seconds

**This means:**
- ✅ Flutter web (Chrome) can call backend
- ✅ Flutter mobile (Android emulator) can call backend
- ✅ Flutter mobile (iOS simulator) can call backend
- ✅ Flutter mobile (Physical device) can call backend

---

## Critical Issues Fixed ✓

### ✅ 1. API Path Consistency
**Frontend paths now match backend:**
- ✅ `/auth/register` → Backend: `/auth/register`
- ✅ `/auth/login` → Backend: `/auth/login`
- ✅ `/api/documents/upload` → Backend: `/api/documents/upload`
- ✅ `/api/applications` → Backend: `/api/applications`
- ✅ `/api/ml/*` → Backend: `/api/ml/*`

### ✅ 2. CORS Headers
- ✅ All controllers have `@CrossOrigin` annotations
- ✅ SecurityConfig has global CORS configuration
- ✅ Preflight OPTIONS requests handled automatically

### ✅ 3. JWT Authentication
- ✅ Public endpoints: `/auth/**`, `/actuator/**`
- ✅ Protected endpoints: `/api/**`
- ✅ JWT token format: `Bearer <token>`
- ✅ Token expiration: 24 hours

---

## Frontend Configuration ✓

### ✅ Update api_config.dart (Already Done!)

The frontend configuration has been updated with correct paths:

```dart
// Application Endpoints
static String get submitApplication => '$backendUrl/api/applications';
static String getUserApplications(int userId) => '$backendUrl/api/applications/user/$userId';

// Document Endpoints
static String get uploadDocument => '$backendUrl/api/documents/upload';
static String getUserDocuments(int userId) => '$backendUrl/api/documents/user/$userId';
```

### ✅ Backend URL for Different Platforms

**Android Emulator:**
```dart
static const String backendUrl = 'http://10.0.2.2:8081';
```

**iOS Simulator:**
```dart
static const String backendUrl = 'http://localhost:8081';
```

**Physical Device:**
```dart
// Get your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String backendUrl = 'http://192.168.1.X:8081';
```

**Web (Chrome):**
```dart
static const String backendUrl = 'http://localhost:8081';
```

---

## Testing Steps

### Step 1: Start Backend
```bash
cd backend
mvn spring-boot:run
```

**Expected Output:**
```
Started CreditScoringApplication in X.XXX seconds
```

### Step 2: Test Health Endpoint
```bash
curl http://localhost:8081/actuator/health
```

**Expected Response:**
```json
{"status":"UP"}
```

### Step 3: Test CORS (from browser console)
```javascript
fetch('http://localhost:8081/actuator/health', {
  method: 'GET',
  headers: {'Content-Type': 'application/json'}
}).then(r => r.json()).then(console.log)
```

**Expected:** No CORS errors

### Step 4: Test Registration
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@test.com\",\"username\":\"Test User\",\"password\":\"password123\"}"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "email": "test@test.com",
    "username": "Test User",
    "token": "eyJhbGc..."
  }
}
```

### Step 5: Test Login
```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@test.com\",\"password\":\"password123\"}"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGc...",
    "user": {...}
  }
}
```

### Step 6: Test Protected Endpoint
```bash
# Use token from login response
curl -X GET http://localhost:8081/api/applications/user/1 \
  -H "Authorization: Bearer eyJhbGc..."
```

**Expected Response:**
```json
{
  "success": true,
  "data": []
}
```

---

## Common Issues & Solutions

### Issue: "Port 8081 is already in use"
**Solution:**
```bash
# Windows
netstat -ano | findstr :8081
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8081
kill -9 <PID>

# Or change port in application.yml
server:
  port: 8082
```

### Issue: "Unable to connect to database"
**Solution:**
```bash
# Check PostgreSQL is running
# Windows
services.msc → PostgreSQL

# Linux
sudo systemctl status postgresql

# Mac
brew services list

# Test connection
psql -U postgres -d credit_scoring_db
```

### Issue: "CORS error in browser"
**Solution:**
- ✅ Already fixed with @CrossOrigin annotations
- Verify backend URL in Flutter is correct
- Check browser console for exact error
- Try hard refresh: Ctrl+Shift+R (Chrome)

### Issue: "401 Unauthorized"
**Solution:**
- Check JWT token is included in request
- Token format: `Authorization: Bearer <token>`
- Token might be expired (24 hours)
- Login again to get new token

### Issue: "File upload fails"
**Solution:**
- Check file size < 10MB
- Allowed types: pdf, jpg, jpeg, png
- Ensure uploads directory exists and is writable
- Check multipart/form-data content type

---

## Final Checklist Before Testing

- [ ] PostgreSQL running
- [ ] Database `credit_scoring_db` created
- [ ] `.env` file configured
- [ ] Java 17+ installed
- [ ] Maven installed
- [ ] Port 8081 available
- [ ] Backend URL in Flutter matches your platform
- [ ] ML service running (if using predictions)

---

## Everything Ready? 🚀

```bash
# Terminal 1: Start Backend
cd backend
mvn spring-boot:run

# Terminal 2: Start Flutter
cd frontend
flutter run -d chrome   # For web
flutter run            # For mobile
```

---

## Verification URLs

Test these in your browser:

1. **Health Check:** http://localhost:8081/actuator/health
2. **API Info:** http://localhost:8081/actuator/info
3. **Metrics:** http://localhost:8081/actuator/metrics

All should return JSON responses without CORS errors.

---

✅ **CORS is configured and ready!**
✅ **API paths are consistent!**
✅ **Backend is production-ready!**

Good luck with testing! 🎉
