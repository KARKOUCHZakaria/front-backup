# Quick Reference Card

## 🚀 Start Commands

```bash
# Start Backend
cd backend
mvn spring-boot:run

# Backend will run on: http://localhost:8081
```

## 🔑 Environment Variables

Create `.env` file in backend folder:
```bash
DB_USERNAME=postgres
DB_PASSWORD=postgres
JWT_SECRET=YourSuperSecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLong
ML_SERVICE_URL=http://localhost:8000
FILE_UPLOAD_DIR=./uploads
```

## 📊 Database Setup

```sql
-- Create database
CREATE DATABASE credit_scoring_db;

-- Tables are created automatically by Flyway on first run
```

## 🌐 Main Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/auth/register` | POST | ❌ | Register user |
| `/auth/login` | POST | ❌ | Login user |
| `/api/applications` | POST | ✅ | Submit application |
| `/api/applications/user/{id}` | GET | ✅ | Get applications |
| `/api/documents/upload` | POST | ✅ | Upload document |
| `/api/ml/explain` | POST | ✅ | Get SHAP values |

## 📱 Frontend Configuration

Update `frontend/lib/src/config/api_config.dart`:

```dart
// For Android Emulator
static const String backendUrl = 'http://10.0.2.2:8081';

// For Physical Device
static const String backendUrl = 'http://YOUR_IP:8081';
```

## 🧪 Quick Test

```bash
# Health check
curl http://localhost:8081/actuator/health

# Register
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"Test","password":"pass123"}'

# Login (returns token)
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"pass123"}'
```

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 8081 in use | Change in `application.yml`: `server.port: 8082` |
| Database error | Check PostgreSQL running: `psql -U postgres` |
| ML service error | Check ML service: `curl http://localhost:8000/health` |
| JWT error | Verify JWT_SECRET is set (256+ bits) |

## 📂 Project Structure

```
backend/
├── src/main/java/.../
│   ├── controller/      → REST endpoints
│   ├── service/         → Business logic
│   ├── repository/      → Database queries
│   ├── entity/          → Database models
│   ├── dto/             → API models
│   └── security/        → JWT & auth
├── src/main/resources/
│   ├── application.yml  → Configuration
│   └── db/migration/    → SQL scripts
└── pom.xml              → Dependencies
```

## 📄 Documentation Files

- `README.md` - Full setup guide
- `API_DOCUMENTATION.md` - API reference
- `ARCHITECTURE.md` - System design
- `IMPLEMENTATION_SUMMARY.md` - Feature overview

## 🎯 Default Credentials (for testing)

```
Email: demo@example.com
Password: password123
```

---

**Need help?** Check README.md for detailed instructions
