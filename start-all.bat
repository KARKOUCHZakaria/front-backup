@echo off
echo ========================================
echo Credit Scoring App - Start All Services
echo ========================================
echo.

echo Starting services in separate windows...
echo.

echo [1/3] Starting ML Service (Python FastAPI)...
start "ML Service - Port 8000" cmd /k "cd /d d:\1 UNICA\Projet\ba\front-backup\ml && python main.py"
timeout /t 3 /nobreak >nul

echo [2/3] Starting Backend Service (Spring Boot)...
start "Backend Service - Port 8081" cmd /k "cd /d d:\1 UNICA\Projet\ba\front-backup\backend && java -jar target\credit-scoring-backend-1.0.0.jar"
timeout /t 5 /nobreak >nul

echo [3/3] Starting Frontend (Flutter)...
start "Frontend (Flutter)" cmd /k "cd /d d:\1 UNICA\Projet\ba\front-backup\frontend && flutter run -d chrome"

echo.
echo ========================================
echo All services started!
echo ========================================
echo.
echo Services:
echo   ML:       http://localhost:8000
echo   Backend:  http://localhost:8081
echo   Frontend: http://localhost:[dynamic]
echo.
echo Test Files: test-documents/
echo   - Pay Slips x3
echo   - Tax Declaration
echo   - Bank Statement
echo   - CIN Images x4
echo.
echo See TESTING_GUIDE.md for complete testing workflow
echo.
pause
