@echo off
REM Docker Stop Script for Windows

echo Stopping all CreditAI services...
echo.

docker-compose stop

echo.
echo Services stopped successfully!
echo.
echo To start again, run: docker-start.bat
echo To remove all data, run: docker-compose down -v
echo.
pause
