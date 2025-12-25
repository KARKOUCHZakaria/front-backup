# CreditAI - Complete Dockerized Stack

Complete AI-powered credit scoring platform with automated CIN (Moroccan ID) verification using OCR.

## 🚀 Quick Start with Docker (Recommended)

**Prerequisites:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed
- 4GB RAM available
- 10GB disk space

**Start all services in one command:**

Windows:
```cmd
docker-start.bat
```

Linux/macOS:
```bash
chmod +x docker-start.sh
./docker-start.sh
```

**That's it!** All services will start automatically:
- ✅ PostgreSQL database
- ✅ ML OCR service (Python + Tesseract)
- ✅ Backend API (Spring Boot)
- ✅ Frontend (Flutter Web)

Access at: **http://localhost:3000**

## 📦 What's Included

### Services

| Service | Technology | Port | Purpose |
|---------|-----------|------|---------|
| **Frontend** | Flutter Web + Nginx | 3000 | User interface |
| **Backend** | Spring Boot + Java 21 | 8081 | REST API, authentication |
| **ML Service** | Python + FastAPI + Tesseract | 8000 | CIN OCR extraction |
| **Database** | PostgreSQL 15 | 5432 | Data storage |

### Features

- ✅ User registration and authentication (JWT)
- ✅ Credit application submission
- ✅ CIN photo upload and automatic verification
- ✅ ML-powered CIN OCR with Arabic support
- ✅ Identity verification workflow
- ✅ Document management
- ✅ Profile management
- ✅ Responsive design (mobile, tablet, desktop)

## 🎯 Architecture

```
┌────────────────────────────────────────────────────────────┐
│                     Docker Network                          │
│                                                             │
│  Frontend (Nginx)  →  Backend (Java)  →  ML (Python)      │
│   Port 3000           Port 8081          Port 8000         │
│       ↓                   ↓                                │
│       └───────────→  PostgreSQL                            │
│                     Port 5432                              │
└────────────────────────────────────────────────────────────┘
```

**Data Flow:**
1. User uploads CIN photo via Frontend
2. Backend receives image and calls ML Service
3. ML Service: Preprocess → OCR → Parse → Return structured data
4. Backend validates extracted CIN matches user input
5. If valid: Save photo + Update user as verified
6. Frontend shows verified badge

## 📋 Manual Docker Commands

If you prefer manual control:

**Build and start:**
```bash
docker-compose up -d --build
```

**View logs:**
```bash
docker-compose logs -f
```

**Check status:**
```bash
docker-compose ps
```

**Stop services:**
```bash
docker-compose stop
```

**Remove everything:**
```bash
docker-compose down -v
```

## 🔗 Service URLs

After starting with Docker:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8081
- **Backend Swagger**: http://localhost:8081/swagger-ui.html
- **ML Service**: http://localhost:8000
- **ML API Docs**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432 (user: creditai, password: creditai_password_2024)

## 🧪 Testing

### Quick API Test

**Register user:**
```bash
curl -X POST http://localhost:8081/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "Test123456"
  }'
```

**Test ML OCR:**
```bash
curl -X POST http://localhost:8000/ocr/cin \
  -F "file=@path/to/cin.jpg" \
  -F "enhance=true"
```

**Health checks:**
```bash
curl http://localhost:3000           # Frontend
curl http://localhost:8081/actuator/health  # Backend
curl http://localhost:8000/health           # ML Service
```

### Complete Test Flow

1. Open http://localhost:3000
2. Click "Register" → Fill form → Submit
3. Login with credentials
4. Navigate to Profile
5. Click "Verify Identity"
6. Enter CIN number (e.g., AB123456)
7. Upload CIN photo
8. Wait for ML processing
9. See verified badge ✅

## 🔧 Configuration

### Using Cloud Database (Aiven)

Edit `docker-compose.yml`:

```yaml
services:
  backend:
    environment:
      # Use Aiven PostgreSQL
      - SPRING_DATASOURCE_URL=jdbc:postgresql://your-aiven-url.com:20506/defaultdb?sslmode=require
      - SPRING_DATASOURCE_USERNAME=avnadmin
      - SPRING_DATASOURCE_PASSWORD=your_password
    
    depends_on:
      # Remove postgres dependency
      ml-service:
        condition: service_healthy
```

Remove or comment out the `postgres` service.

### Environment Variables

Create `.env` file (copy from `.env.example`):

```env
POSTGRES_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_key_at_least_256_bits
ML_SERVICE_URL=http://ml-service:8000
```

Update `docker-compose.yml`:
```yaml
environment:
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  - JWT_SECRET=${JWT_SECRET}
```

## 🐛 Troubleshooting

### Services won't start

**Check Docker is running:**
```bash
docker ps
```

**View error logs:**
```bash
docker-compose logs backend
docker-compose logs ml-service
```

**Clean restart:**
```bash
docker-compose down -v
docker-compose up -d --build
```

### Frontend shows 502 Bad Gateway

**Check backend is healthy:**
```bash
curl http://localhost:8081/actuator/health
```

**Restart services:**
```bash
docker-compose restart backend frontend
```

### ML OCR not working

**Check Tesseract in ML container:**
```bash
docker-compose exec ml-service tesseract --version
docker-compose exec ml-service tesseract --list-langs
```

Should show: `eng`, `ara`

**Rebuild ML service:**
```bash
docker-compose build --no-cache ml-service
docker-compose up -d ml-service
```

### Database connection errors

**Check PostgreSQL is running:**
```bash
docker-compose ps postgres
```

**Access database:**
```bash
docker-compose exec postgres psql -U creditai -d creditai
```

**Reset database:**
```bash
docker-compose down -v
docker-compose up -d postgres
# Wait 10 seconds
docker-compose up -d backend
```

### Port already in use

**Windows:**
```cmd
netstat -ano | findstr :3000
netstat -ano | findstr :8081
netstat -ano | findstr :8000
```

**Linux/macOS:**
```bash
lsof -i :3000
lsof -i :8081
lsof -i :8000
```

**Solution:** Stop the conflicting process or change port in `docker-compose.yml`

## 📊 Monitoring

**View resource usage:**
```bash
docker stats
```

**Check disk usage:**
```bash
docker system df
```

**Container details:**
```bash
docker inspect creditai-backend
docker inspect creditai-ml
```

## 🔒 Production Deployment

### Security Checklist

- [ ] Change all default passwords
- [ ] Use environment variables for secrets
- [ ] Enable SSL/TLS (HTTPS)
- [ ] Remove exposed ports for internal services
- [ ] Set up firewall rules
- [ ] Enable authentication between services
- [ ] Implement rate limiting
- [ ] Set up monitoring and alerts
- [ ] Configure automated backups
- [ ] Use production database (Aiven)
- [ ] Review and update CORS settings

### Recommended Changes

1. **Add reverse proxy (nginx/traefik) with SSL:**
```yaml
services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs
```

2. **Use Docker secrets:**
```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

services:
  backend:
    secrets:
      - db_password
      - jwt_secret
```

3. **Add Redis for caching:**
```yaml
services:
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
```

## 📁 Project Structure

```
front-backup/
├── docker-compose.yml       # Orchestration config
├── docker-start.bat         # Windows startup script
├── docker-start.sh          # Linux/macOS startup script
├── DOCKER_GUIDE.md          # Complete Docker documentation
├── .env.example             # Environment variables template
│
├── backend/                 # Spring Boot API
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/
│
├── frontend/                # Flutter Web App
│   ├── Dockerfile
│   ├── pubspec.yaml
│   └── lib/
│
└── ml/                      # Python ML Service
    ├── Dockerfile
    ├── requirements.txt
    ├── main.py
    └── services/
```

## 📖 Documentation

- [DOCKER_GUIDE.md](DOCKER_GUIDE.md) - Complete Docker documentation
- [ML_INTEGRATION_COMPLETE.md](ML_INTEGRATION_COMPLETE.md) - ML OCR integration details
- [backend/README.md](backend/README.md) - Backend API documentation
- [frontend/README.md](frontend/README.md) - Frontend documentation
- [ml/README.md](ml/README.md) - ML service documentation
- [ml/QUICK_START.md](ml/QUICK_START.md) - ML service quick start
- [ml/TESTING_GUIDE.md](ml/TESTING_GUIDE.md) - Testing guide

## 🤝 Development

### Without Docker (Development Mode)

If you want to run services individually for development:

**1. Start ML Service:**
```bash
cd ml
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

**2. Start Backend:**
```bash
cd backend
./mvnw spring-boot:run  # Windows: mvnw.cmd spring-boot:run
```

**3. Start Frontend:**
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### Hot Reload

For development with hot reload:

**Backend:**
- Use Spring Boot DevTools (already configured)
- Changes auto-reload

**Frontend:**
- Run `flutter run -d chrome`
- Hot reload with `r` key

**ML Service:**
- Run `uvicorn main:app --reload`
- Auto-reloads on file changes

## 🎓 Next Steps

1. **Start services:** Run `docker-start.bat` (Windows) or `./docker-start.sh` (Linux/macOS)
2. **Test application:** Open http://localhost:3000
3. **Register user:** Create test account
4. **Upload CIN:** Test ML OCR verification
5. **Review logs:** `docker-compose logs -f`
6. **Read documentation:** Check DOCKER_GUIDE.md for advanced usage

## 🆘 Support

**Common Issues:**
- Check [DOCKER_GUIDE.md](DOCKER_GUIDE.md) troubleshooting section
- View logs: `docker-compose logs -f [service-name]`
- Clean restart: `docker-compose down -v && docker-compose up -d --build`

**Resources:**
- Docker Documentation: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Spring Boot: https://spring.io/projects/spring-boot
- Flutter: https://flutter.dev/
- FastAPI: https://fastapi.tiangolo.com/

## ✅ Features Checklist

### Authentication
- [x] User registration
- [x] User login (JWT)
- [x] Password hashing
- [x] Token refresh

### CIN Verification
- [x] CIN photo upload
- [x] ML OCR extraction
- [x] Automatic verification
- [x] Arabic text support
- [x] Confidence scoring
- [x] Image preprocessing
- [x] Identity badge

### Profile Management
- [x] View profile
- [x] Update profile
- [x] Upload CIN photo
- [x] View verification status
- [x] Download CIN photo

### Credit Application
- [x] Submit application
- [x] View applications
- [x] Upload documents
- [x] Application status

### Responsive Design
- [x] Mobile optimized
- [x] Tablet support
- [x] Desktop layout
- [x] Dark/light theme

### Docker Deployment
- [x] Multi-service orchestration
- [x] Health checks
- [x] Volume persistence
- [x] Network isolation
- [x] Resource limits
- [x] Auto-restart
- [x] One-command startup

---

**Built with ❤️ using Spring Boot, Flutter, FastAPI, and Docker**

**Ready to deploy!** 🚀🐳
