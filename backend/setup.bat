@echo off
REM Setup script for Ethical AI Credit Scoring Backend (Windows)

echo ===================================
echo Backend Setup Script
echo ===================================
echo.

REM Check Java version
echo Checking Java version...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo X Java is not installed. Please install Java 17 or higher.
    pause
    exit /b 1
)
echo + Java is installed

REM Check Maven
echo Checking Maven...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo X Maven is not installed. Please install Maven 3.8+.
    pause
    exit /b 1
)
echo + Maven is installed

REM Create environment file
echo.
echo Creating environment file...
(
echo # Database Configuration
echo DB_USERNAME=postgres
echo DB_PASSWORD=postgres
echo.
echo # JWT Secret ^(256+ bits^)
echo JWT_SECRET=YourSuperSecretKeyForJWTTokenGenerationMustBeAtLeast256BitsLong
echo.
echo # ML Service URL
echo ML_SERVICE_URL=http://localhost:8000
echo.
echo # File Upload Directory
echo FILE_UPLOAD_DIR=./uploads
) > .env

echo + Environment file created ^(.env^)

REM Create uploads directory
echo.
echo Creating uploads directory...
if not exist "uploads" mkdir uploads
echo + Uploads directory created

REM Build project
echo.
echo Building project...
call mvn clean install -DskipTests

if %errorlevel% equ 0 (
    echo + Build successful
) else (
    echo X Build failed
    pause
    exit /b 1
)

REM Summary
echo.
echo ===================================
echo Setup Complete!
echo ===================================
echo.
echo Next steps:
echo 1. Update .env file with your database credentials
echo 2. Ensure PostgreSQL is running on localhost:5432
echo 3. Create database: psql -U postgres -c "CREATE DATABASE credit_scoring_db;"
echo 4. Ensure ML service is running on localhost:8000
echo 5. Run: mvn spring-boot:run
echo.
echo The backend will be available at:
echo   - http://localhost:8081
echo   - http://10.0.2.2:8081 ^(Android emulator^)
echo.
pause
