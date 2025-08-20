@echo off
echo 🚀 Quick Start Guide for Bookshop Application
echo ==============================================
echo.

echo 📋 Prerequisites Check:
echo 1. Java 17+ installed
echo 2. MySQL running (XAMPP)
echo 3. Node.js 18+ installed
echo.

echo 🔍 Checking if services are running...
echo.

echo 📚 Starting Backend...
start "Backend" cmd /k "cd bookshop-backend && echo Starting Spring Boot... && mvn spring-boot:run"

echo.
echo ⏳ Waiting for backend to start (15 seconds)...
timeout /t 15 /nobreak > nul

echo.
echo 🌐 Starting Frontend...
start "Frontend" cmd /k "cd bookshop-frontend && echo Starting React... && npm run dev"

echo.
echo ✅ Services started!
echo.
echo 📍 Backend: http://localhost:8080
echo 🌐 Frontend: http://localhost:5173
echo 🗄️  Database: localhost:3306
echo.
echo 🔑 Default Admin Login:
echo    Email: admin@bookshop.com
echo    Password: admin123
echo.
echo 🔍 If you have authentication issues:
echo    1. Check the DEBUG_GUIDE.md file
echo    2. Use the debug button in admin pages
echo    3. Check browser console for errors
echo.
echo Press any key to open the application...
pause > nul

start http://localhost:5173
