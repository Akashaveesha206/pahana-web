@echo off
echo 🚀 Starting Bookshop Development Environment...

echo.
echo 📚 Starting Backend...
start "Backend" cmd /k "cd bookshop-backend && mvn spring-boot:run"

echo.
echo ⏳ Waiting for backend to start...
timeout /t 10 /nobreak > nul

echo.
echo 🌐 Starting Frontend...
start "Frontend" cmd /k "cd bookshop-frontend && npm run dev"

echo.
echo ✅ Development environment started!
echo.
echo 📍 Backend: http://localhost:8080
echo 🌐 Frontend: http://localhost:5173
echo 🗄️  Database: localhost:3306
echo.
echo Press any key to open the application...
pause > nul

start http://localhost:5173
