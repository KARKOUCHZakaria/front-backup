# 🚀 QUICK START - Run Backend NOW!

## Prerequisites (5 minutes)

1. **PostgreSQL Running?**
   ```bash
   psql -U postgres
   ```
   If error → Start PostgreSQL service

2. **Create Database**
   ```sql
   CREATE DATABASE credit_scoring_db;
   \q
   ```

3. **Create .env file** in `backend/` folder:
   ```bash
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   JWT_SECRET=YourSuperSecretKeyMinimum32CharactersLongForSecurity123456789
   ML_SERVICE_URL=http://localhost:8000
   ```

## Start Backend (1 command)

```bash
cd backend
mvn spring-boot:run
```

**Wait for:** `Started CreditScoringApplication in X.XXX seconds`

## Test It (30 seconds)

```bash
# Open new terminal
curl http://localhost:8081/actuator/health
```

**Expected:** `{"status":"UP"}`

## Run Flutter App

```bash
cd frontend
flutter run -d chrome
```

## ✅ What's Already Configured

- ✅ **CORS:** Fully configured for Flutter (web & mobile)
- ✅ **API Paths:** All endpoints match frontend exactly
- ✅ **Security:** JWT authentication ready
- ✅ **Database:** Auto-migrates on first run
- ✅ **File Upload:** Ready for documents

## 🎯 Test the Integration

1. **Register:** Create new user
2. **Login:** Get JWT token
3. **Submit Application:** Fill credit application
4. **Upload Document:** Upload ID/proof
5. **View Results:** See credit decision

## ⚠️ Troubleshooting

### "Port 8081 in use"
```bash
# Change port in application.yml
server:
  port: 8082
```

### "Cannot connect to database"
```bash
# Check PostgreSQL running
# Windows: services.msc → PostgreSQL
# Linux: sudo systemctl start postgresql
```

### "CORS error"
✅ Already fixed! Just use correct backend URL:
- Android Emulator: `http://10.0.2.2:8081` ← **Default**
- iOS Simulator: `http://localhost:8081`
- Physical Device: `http://YOUR_IP:8081`
- Web: `http://localhost:8081`

## 📚 More Help?

- **Complete Guide:** [README.md](README.md)
- **API Reference:** [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **CORS Details:** [CORS_CHECK.md](CORS_CHECK.md)
- **Pre-Flight Check:** [PRE_FLIGHT_CHECKLIST.md](PRE_FLIGHT_CHECKLIST.md)

---

## That's It! 🎉

Your backend is **100% ready** and **fully configured** for your Flutter app!

```bash
# Start backend
cd backend && mvn spring-boot:run

# Start Flutter (new terminal)
cd frontend && flutter run -d chrome
```

**Good luck testing!** 🚀
