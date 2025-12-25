@echo off
REM Backend Test Script for Windows
REM This script tests all critical endpoints

echo.
echo =====================================
echo   Backend API Test Script
echo =====================================
echo.

set BACKEND_URL=http://localhost:8081

echo [1/6] Testing Health Endpoint...
curl -s %BACKEND_URL%/actuator/health
echo.
echo.

echo [2/6] Testing Registration...
curl -s -X POST %BACKEND_URL%/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"username\":\"Test User\",\"password\":\"password123\",\"phoneNumber\":\"+212600000000\"}"
echo.
echo.

echo [3/6] Testing Login...
for /f "tokens=*" %%i in ('curl -s -X POST %BACKEND_URL%/auth/login -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"password\":\"password123\"}"') do set LOGIN_RESPONSE=%%i

REM Extract token (simplified - in production use jq or similar)
echo %LOGIN_RESPONSE%
echo.
echo.

echo [4/6] Testing CORS Preflight...
curl -s -X OPTIONS %BACKEND_URL%/api/applications ^
  -H "Origin: http://localhost:3000" ^
  -H "Access-Control-Request-Method: POST" ^
  -H "Access-Control-Request-Headers: Content-Type, Authorization" ^
  -v
echo.
echo.

echo [5/6] Testing Protected Endpoint (without token - should fail)...
curl -s -X GET %BACKEND_URL%/api/applications/user/1
echo.
echo.

echo [6/6] Backend Logs Check...
echo Check the backend terminal for any errors
echo.

echo.
echo =====================================
echo   Test Complete!
echo =====================================
echo.
echo Next Steps:
echo 1. Check all responses above
echo 2. Verify no CORS errors
echo 3. Verify 401 error for protected endpoint without token
echo 4. Test with Flutter app
echo.

pause
