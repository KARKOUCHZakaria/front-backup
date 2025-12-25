@echo off
REM Docker Quick Start Script for Windows

echo ========================================
echo  CreditAI Docker Deployment
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [OK] Docker is installed
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo [OK] Docker is running
echo.

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] docker-compose is not installed
    pause
    exit /b 1
)

echo [OK] docker-compose is installed
echo.

echo Starting all services...
echo This may take 5-10 minutes on first run (downloading images and building)
echo.

REM Build and start services
docker-compose up -d --build

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to start services
    echo Run 'docker-compose logs' to see errors
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Services Started Successfully!
echo ========================================
echo.
echo Waiting for services to be healthy...
timeout /t 30 /nobreak >nul

REM Check service status
docker-compose ps

echo.
echo ========================================
echo  Access Your Application:
echo ========================================
echo.
echo Frontend:          http://localhost:3000
echo Backend API:       http://localhost:8081
echo Backend Swagger:   http://localhost:8081/swagger-ui.html
echo ML Service:        http://localhost:8000
echo ML API Docs:       http://localhost:8000/docs
echo PostgreSQL:        localhost:5432
echo.
echo ========================================
echo  Useful Commands:
echo ========================================
echo.
echo View logs:         docker-compose logs -f
echo Stop services:     docker-compose stop
echo Restart services:  docker-compose restart
echo Remove all:        docker-compose down -v
echo.
echo Press any key to open frontend in browser...
pause >nul

start http://localhost:3000

echo.
echo To view logs, run: docker-compose logs -f
echo.
pause
