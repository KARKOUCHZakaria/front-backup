# Docker Deployment Guide

Complete guide to run the entire CreditAI application stack using Docker.

## 📦 What's Included

The Docker setup includes 4 services:

1. **PostgreSQL Database** (port 5432)
   - PostgreSQL 15 Alpine
   - Local database for development
   - Optional (can use Aiven cloud instead)

2. **ML Service** (port 8000)
   - Python 3.11 + FastAPI
   - Tesseract OCR with Arabic support
   - CIN image processing and extraction

3. **Backend** (port 8081)
   - Spring Boot + Java 21
   - REST API
   - JWT authentication
   - File uploads

4. **Frontend** (port 3000)
   - Flutter Web (built)
   - Nginx web server
   - Reverse proxy to backend

## 🚀 Quick Start

### Prerequisites

- Docker Desktop installed (Windows/macOS) or Docker Engine (Linux)
- Docker Compose v2.0+
- At least 4GB RAM available
- 10GB disk space

**Install Docker:**
- Windows/macOS: https://www.docker.com/products/docker-desktop
- Linux: https://docs.docker.com/engine/install/

**Verify installation:**
```bash
docker --version
docker-compose --version
```

### Start All Services

1. **Navigate to project root:**
```bash
cd "d:\1 UNICA\Projet\ba\front-backup"
```

2. **Build and start all services:**
```bash
docker-compose up -d --build
```

This will:
- Build Docker images for ML, Backend, Frontend
- Pull PostgreSQL image
- Start all 4 containers
- Create network and volumes

3. **Check status:**
```bash
docker-compose ps
```

Expected output:
```
NAME                  STATUS              PORTS
creditai-postgres     Up (healthy)        0.0.0.0:5432->5432/tcp
creditai-ml           Up (healthy)        0.0.0.0:8000->8000/tcp
creditai-backend      Up (healthy)        0.0.0.0:8081->8081/tcp
creditai-frontend     Up (healthy)        0.0.0.0:3000->80/tcp
```

4. **View logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f ml-service
docker-compose logs -f frontend
```

5. **Access application:**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8081
- **Backend Swagger**: http://localhost:8081/swagger-ui.html
- **ML Service**: http://localhost:8000
- **ML API Docs**: http://localhost:8000/docs
- **PostgreSQL**: localhost:5432

## 🔧 Configuration

### Using Cloud Database (Aiven)

If you want to use Aiven PostgreSQL instead of local:

1. **Edit `docker-compose.yml`:**
```yaml
services:
  backend:
    environment:
      # Comment out local PostgreSQL
      # - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/creditai
      
      # Uncomment Aiven
      - SPRING_DATASOURCE_URL=jdbc:postgresql://your-aiven-instance.aivencloud.com:20506/defaultdb?sslmode=require
      - SPRING_DATASOURCE_USERNAME=avnadmin
      - SPRING_DATASOURCE_PASSWORD=your_aiven_password_here
    
    depends_on:
      # Remove postgres dependency
      # postgres:
      #   condition: service_healthy
      ml-service:
        condition: service_healthy
```

2. **Remove PostgreSQL service:**
```yaml
# Comment out or remove entire postgres service
```

3. **Restart backend:**
```bash
docker-compose up -d backend
```

### Environment Variables

Edit `docker-compose.yml` to customize:

**Backend:**
```yaml
environment:
  - SPRING_DATASOURCE_URL=...
  - JWT_SECRET=YourSecretKey
  - ML_SERVICE_URL=http://ml-service:8000
  - CORS_ALLOWED_ORIGINS=http://localhost:3000
```

**ML Service:**
```yaml
environment:
  - LOG_LEVEL=INFO  # or DEBUG
  - PYTHONUNBUFFERED=1
```

**Frontend:**
```yaml
environment:
  - NGINX_HOST=localhost
```

## 📋 Docker Commands

### Basic Operations

**Start services:**
```bash
docker-compose up -d
```

**Stop services:**
```bash
docker-compose stop
```

**Restart services:**
```bash
docker-compose restart
```

**Stop and remove containers:**
```bash
docker-compose down
```

**Stop and remove everything (including volumes):**
```bash
docker-compose down -v
```

### Build Commands

**Rebuild all images:**
```bash
docker-compose build
```

**Rebuild specific service:**
```bash
docker-compose build backend
docker-compose build ml-service
docker-compose build frontend
```

**Build without cache:**
```bash
docker-compose build --no-cache
```

**Build and start:**
```bash
docker-compose up -d --build
```

### Logs and Debugging

**View logs:**
```bash
# All services
docker-compose logs

# Follow logs (live)
docker-compose logs -f

# Specific service
docker-compose logs backend
docker-compose logs ml-service

# Last 100 lines
docker-compose logs --tail=100 backend
```

**Execute commands in container:**
```bash
# Backend
docker-compose exec backend bash

# ML Service
docker-compose exec ml-service bash

# PostgreSQL
docker-compose exec postgres psql -U creditai -d creditai
```

**Check service health:**
```bash
docker-compose ps
```

### Data Management

**Backup PostgreSQL:**
```bash
docker-compose exec postgres pg_dump -U creditai creditai > backup.sql
```

**Restore PostgreSQL:**
```bash
docker-compose exec -T postgres psql -U creditai creditai < backup.sql
```

**View volumes:**
```bash
docker volume ls | grep creditai
```

**Inspect volume:**
```bash
docker volume inspect creditai-postgres-data
docker volume inspect creditai-backend-uploads
```

**Remove volumes:**
```bash
docker volume rm creditai-postgres-data
docker volume rm creditai-backend-uploads
docker volume rm creditai-backend-logs
```

## 🔍 Testing

### Health Checks

**Test each service:**

1. **PostgreSQL:**
```bash
docker-compose exec postgres pg_isready -U creditai
```

2. **ML Service:**
```bash
curl http://localhost:8000/health
```

3. **Backend:**
```bash
curl http://localhost:8081/actuator/health
```

4. **Frontend:**
```bash
curl http://localhost:3000
```

### API Testing

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

**Login:**
```bash
curl -X POST http://localhost:8081/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123456"
  }'
```

**Test ML OCR:**
```bash
curl -X POST http://localhost:8000/ocr/cin \
  -F "file=@path/to/cin.jpg" \
  -F "enhance=true"
```

## 🐛 Troubleshooting

### Service Won't Start

**Check logs:**
```bash
docker-compose logs backend
```

**Check if port is already in use:**
```bash
# Windows
netstat -ano | findstr :8081

# Linux/macOS
lsof -i :8081
```

**Solution:** Stop conflicting process or change port in `docker-compose.yml`

### Database Connection Error

**Error:** `Connection refused` or `Unknown database`

**Check PostgreSQL is running:**
```bash
docker-compose ps postgres
```

**Check logs:**
```bash
docker-compose logs postgres
```

**Recreate database:**
```bash
docker-compose down -v
docker-compose up -d postgres
# Wait for healthy status
docker-compose up -d backend
```

### ML Service OCR Fails

**Error:** `TesseractNotFoundError`

**Check Tesseract installation:**
```bash
docker-compose exec ml-service tesseract --version
docker-compose exec ml-service tesseract --list-langs
```

Should show: `eng`, `ara`

**Rebuild ML image:**
```bash
docker-compose build --no-cache ml-service
docker-compose up -d ml-service
```

### Frontend Shows 502 Bad Gateway

**Check backend is running:**
```bash
docker-compose ps backend
curl http://localhost:8081/actuator/health
```

**Check nginx configuration:**
```bash
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf
```

**Restart frontend:**
```bash
docker-compose restart frontend
```

### Out of Memory

**Error:** `Cannot allocate memory`

**Check available resources:**
```bash
docker stats
```

**Increase Docker resources:**
- Docker Desktop → Settings → Resources
- Increase RAM to at least 4GB
- Increase CPUs to 2+

**Reduce service limits in `docker-compose.yml`:**
```yaml
deploy:
  resources:
    limits:
      memory: 1G  # Reduce from 2G
```

### Build Fails

**Error:** `failed to solve with frontend dockerfile.v0`

**Clear Docker cache:**
```bash
docker system prune -a
```

**Rebuild from scratch:**
```bash
docker-compose build --no-cache --pull
```

### Permission Denied (Linux)

**Error:** `Permission denied` when accessing volumes

**Fix permissions:**
```bash
sudo chown -R $USER:$USER volumes/
```

**Or run with sudo:**
```bash
sudo docker-compose up -d
```

## 📊 Monitoring

### Resource Usage

**View real-time stats:**
```bash
docker stats
```

**Container details:**
```bash
docker-compose ps
```

**Inspect service:**
```bash
docker inspect creditai-backend
docker inspect creditai-ml
```

### Logs Management

**Rotate logs:**

Edit `docker-compose.yml`:
```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

**View disk usage:**
```bash
docker system df
```

**Clean up:**
```bash
docker system prune -a --volumes
```

## 🚀 Production Deployment

### Security Recommendations

1. **Change default passwords:**
```yaml
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
JWT_SECRET: ${JWT_SECRET}
```

2. **Use environment file:**

Create `.env`:
```env
POSTGRES_PASSWORD=strong_password_here
JWT_SECRET=your_jwt_secret_here
AIVEN_DB_URL=your_aiven_url
AIVEN_DB_USER=your_user
AIVEN_DB_PASS=your_password
```

Update `docker-compose.yml`:
```yaml
environment:
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  - JWT_SECRET=${JWT_SECRET}
```

3. **Remove port exposure for internal services:**
```yaml
postgres:
  # Remove ports section (only accessible within network)
  # ports:
  #   - "5432:5432"
```

4. **Add SSL/TLS:**
- Use reverse proxy (nginx/traefik) with Let's Encrypt
- Enable HTTPS for frontend

5. **Limit resource usage:**
- Keep `deploy.resources.limits` in place
- Monitor with `docker stats`

### Performance Tuning

1. **Increase workers:**
```yaml
ml-service:
  command: ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

2. **Add Redis for caching:**
```yaml
services:
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
```

3. **Use production database:**
- Use Aiven PostgreSQL (already configured)
- Or PostgreSQL with persistent volume and backups

### Backup Strategy

**Automated backups:**

Create `backup.sh`:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T postgres pg_dump -U creditai creditai > backup_$DATE.sql
gzip backup_$DATE.sql
```

**Schedule with cron:**
```bash
0 2 * * * /path/to/backup.sh
```

## 📚 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Docker Host                          │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Frontend   │  │   Backend    │  │  ML Service  │    │
│  │   (Nginx)    │  │  (Java 21)   │  │  (Python)    │    │
│  │   Port 3000  │  │   Port 8081  │  │   Port 8000  │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                │
│                  ┌────────┴─────────┐                      │
│                  │   PostgreSQL     │                      │
│                  │   Port 5432      │                      │
│                  └──────────────────┘                      │
│                                                             │
│  Volumes:                                                   │
│  - postgres_data (Database)                                 │
│  - backend_uploads (CIN photos)                             │
│  - backend_logs (Application logs)                          │
│                                                             │
│  Network: creditai-network (bridge)                         │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Next Steps

1. **Start services:** `docker-compose up -d --build`
2. **Check health:** `docker-compose ps`
3. **Test frontend:** http://localhost:3000
4. **Test backend:** http://localhost:8081/swagger-ui.html
5. **Test ML service:** http://localhost:8000/docs
6. **Register user and test CIN verification**

## 📖 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [ML_INTEGRATION_COMPLETE.md](ML_INTEGRATION_COMPLETE.md) - ML service details
- [backend/README.md](backend/README.md) - Backend documentation
- [frontend/README.md](frontend/README.md) - Frontend documentation

## ✅ Quick Reference

**Start everything:**
```bash
docker-compose up -d --build
```

**View logs:**
```bash
docker-compose logs -f
```

**Stop everything:**
```bash
docker-compose down
```

**Clean restart:**
```bash
docker-compose down -v
docker-compose up -d --build
```

**Check health:**
```bash
docker-compose ps
```

**Access services:**
- Frontend: http://localhost:3000
- Backend: http://localhost:8081
- ML Service: http://localhost:8000
- PostgreSQL: localhost:5432

---

**Your complete CreditAI stack is now Dockerized!** 🐳🚀
